module Beaker
  class Docker < Beaker::Hypervisor

    # Docker hypvervisor initializtion
    # Env variables supported:
    # DOCKER_REGISTRY: Docker registry URL
    # DOCKER_HOST: Remote docker host
    # DOCKER_BUILDARGS: Docker buildargs map
    # @param [Host, Array<Host>, String, Symbol] hosts    One or more hosts to act upon,
    #                            or a role (String or Symbol) that identifies one or more hosts.
    # @param [Hash{Symbol=>String}] options Options to pass on to the hypervisor
    def initialize(hosts, options)
      require 'docker'
      @options = options
      @logger = options[:logger] || Beaker::Logger.new
      @hosts = hosts

      # increase the http timeouts as provisioning images can be slow
      default_docker_options = { :write_timeout => 300, :read_timeout => 300 }.merge(::Docker.options || {})
      # Merge docker options from the entry in hosts file
      ::Docker.options = default_docker_options.merge(@options[:docker_options] || {})

      # Ensure that we can correctly communicate with the docker API
      begin
        @docker_version = ::Docker.version
      rescue Excon::Errors::SocketError => e
        raise <<~ERRMSG
          Docker instance not connectable
          Error was: #{e}
          * Check your DOCKER_HOST variable has been set
          * If you are on OSX or Windows, you might not have Docker Machine setup correctly: https://docs.docker.com/machine/
          * If you are using rootless podman, you might need to set up your local socket and service
          ERRMSG
      end

      # Pass on all the logging from docker-api to the beaker logger instance
      ::Docker.logger = @logger

      # Find out what kind of remote instance we are talking against
      if @docker_version['Version'] =~ /swarm/
        @docker_type = 'swarm'
        unless ENV['DOCKER_REGISTRY']
          raise "Using Swarm with beaker requires a private registry. Please setup the private registry and set the 'DOCKER_REGISTRY' env var"
        else
          @registry = ENV['DOCKER_REGISTRY']
        end
      elsif ::Docker.respond_to?(:podman?) && ::Docker.podman?
        @docker_type = 'podman'
      else
        @docker_type = 'docker'
      end
    end

    def install_and_run_ssh(host)
      def host.enable_root_login(host,opts)
        logger.debug("Root login already enabled for #{host}")
      end

      # If the container is running ssh as its init process then this method
      # will cause issues.
      if host[:docker_cmd] =~ /sshd/
        def host.ssh_service_restart
          self[:docker_container].exec(%w(kill -1 1))
        end
      end

      host['dockerfile'] || host['use_image_entry_point']
    end

    def get_container_opts(host, image_name)
      container_opts = {}
      if host['dockerfile']
        container_opts['ExposedPorts'] = {'22/tcp' => {} }
      end

      container_opts.merge! ( {
        'Image' => image_name,
        'Hostname' => host.name,
        'HostConfig' => {
          'PortBindings' => {
            '22/tcp' => [{ 'HostPort' => rand.to_s[2..5], 'HostIp' => '0.0.0.0'}]
          },
          'PublishAllPorts' => true,
          'RestartPolicy' => {
            'Name' => 'always'
          }
        }
      } )
    end

    def get_container_image(host)
      @logger.debug("Creating image")

      if host['use_image_as_is']
        return ::Docker::Image.create('fromImage' => host['image'])
      end

      dockerfile = host['dockerfile']
      if dockerfile
        # assume that the dockerfile is in the repo and tests are running
        # from the root of the repo; maybe add support for external Dockerfiles
        # with external build dependencies later.
        if File.exist?(dockerfile)
          dir = File.expand_path(dockerfile).chomp(dockerfile)
          return ::Docker::Image.build_from_dir(
            dir,
            { 'dockerfile' => dockerfile,
              :rm => true,
              :buildargs => buildargs_for(host)
            }
          )
        else
          raise "Unable to find dockerfile at #{dockerfile}"
        end
      elsif host['use_image_entry_point']
        df = <<-DF
          FROM #{host['image']}
          EXPOSE 22
        DF

        cmd = host['docker_cmd']
        df += cmd if cmd
        return ::Docker::Image.build(df, { rm: true, buildargs: buildargs_for(host) })
      end

      return ::Docker::Image.build(dockerfile_for(host),
                  { rm: true, buildargs: buildargs_for(host) })
    end

    # Nested Docker scenarios
    def nested_docker?
      ENV['DOCKER_IN_DOCKER'] || ENV['WSLENV']
    end

    # Find out where the ssh port is from the container
    # When running on swarm DOCKER_HOST points to the swarm manager so we have to get the
    # IP of the swarm slave via the container data
    # When we are talking to a normal docker instance DOCKER_HOST can point to a remote docker instance.
    def get_ssh_connection_info(container)
      ssh_connection_info = {
        ip: nil,
        port: nil
      }

      container_json = container.json
      network_settings = container_json['NetworkSettings']
      host_config = container_json['HostConfig']

      ip = nil
      port = nil
      # Talking against a remote docker host which is a normal docker host
      if @docker_type == 'docker' && ENV['DOCKER_HOST'] && !ENV.fetch('DOCKER_HOST','').include?(':///') && !nested_docker?
        ip = URI.parse(ENV['DOCKER_HOST']).host
      else
        # Swarm or local docker host
        if in_container? && !nested_docker?
          gw = network_settings['Gateway']
          ip = gw unless (gw.nil? || gw.empty?)
        else
          # The many faces of container networking

          # Container to container
          if nested_docker?
            ip = network_settings['IPAddress']
            port = 22 if ip && !ip.empty?
          end

          # Host to Container
          unless ip && port
            ip = nil
            port = nil

            port22 = network_settings.dig('PortBindings','22/tcp')
            if port22.nil? && network_settings.key?('Ports')
              port22 = network_settings.dig('Ports','22/tcp')
            end
            ip = port22[0]['HostIp'] if port22
            port = port22[0]['HostPort'] if port22
          end

          # Container through gateway
          unless ip && port
            ip = nil
            port = nil

            ip = network_settings['Gateway']

            if ip && !ip.empty?
              port22 = network_settings.dig('PortBindings','22/tcp')
              port = port22[0]['HostPort'] if port22
            end
          end

          # Legacy fallback
          unless ip && port
            port22 = network_settings.dig('Ports','22/tcp')
            ip = port22[0]["HostIp"] if port22
            port = port22[0]['HostPort'] if port22
          end
        end
      end

      if host_config['NetworkMode'] != 'slirp4netns' && network_settings['IPAddress'] && !network_settings['IPAddress'].empty?
        ip = network_settings['IPAddress'] if ip.nil?
      else
        port22 = network_settings.dig('Ports','22/tcp')
        port = port22[0]['HostPort'] if port22
      end

      ssh_connection_info[:ip] = (ip == '0.0.0.0') ? '127.0.0.1' : ip
      ssh_connection_info[:port] = port || '22'
      ssh_connection_info
    end

    def provision
      @logger.notify "Provisioning docker"

      @hosts.each do |host|
        @logger.notify "provisioning #{host.name}"


        image = get_container_image(host)

        if host['tag']
          image.tag({:repo => host['tag']})
        end

        if @docker_type == 'swarm'
          image_name = "#{@registry}/beaker/#{image.id}"
          ret = ::Docker::Image.search(:term => image_name)
          if ret.first.nil?
            @logger.debug("Image does not exist on registry. Pushing.")
            image.tag({:repo => image_name, :force => true})
            image.push
          end
        else
          image_name = image.id
        end

        ### BEGIN CONTAINER OPTIONS MANGLING ###

        container_opts = get_container_opts(host, image_name)
        if host['dockeropts'] || @options[:dockeropts]
          dockeropts = host['dockeropts'] ? host['dockeropts'] : @options[:dockeropts]
          dockeropts.each do |k,v|
            container_opts[k] = v
          end
        end

        container = find_container(host)

        # Provisioning - Only provision if the host's container can't be found
        # via its name or ID
        if container.nil?
          unless host['mount_folders'].nil?
            container_opts['HostConfig'] ||= {}
            container_opts['HostConfig']['Binds'] = host['mount_folders'].values.map do |mount|
              host_path = File.expand_path(mount['host_path'])
              # When using docker_toolbox and getting a "(Driveletter):/" path, convert windows path to VM mount
              if ENV['DOCKER_TOOLBOX_INSTALL_PATH'] && host_path =~ /^.\:\//
                host_path = "/" + host_path.gsub(/^.\:/, host_path[/^(.)/].downcase)
              end
              a = [ host_path, mount['container_path'] ]
              if mount.has_key?('opts')
                a << mount['opts'] if mount.has_key?('opts')
              else
                a << mount['opts'] = 'z'
              end

              a.join(':')
            end
          end

          if host['docker_env']
            container_opts['Env'] = host['docker_env']
          end

          # Fixup privileges
          #
          # If the user has specified CAPs, then we cannot be privileged
          #
          # If the user has not specified CAPs, we will default to privileged for
          # compatibility with worst practice
          if host['docker_cap_add']
            container_opts['HostConfig']['CapAdd'] = host['docker_cap_add']
            container_opts['HostConfig'].delete('Privileged')
          else
            container_opts['HostConfig']['Privileged'] = container_opts['HostConfig']['Privileged'].nil? ? true : container_opts['HostConfig']['Privileged']
          end

          if host['docker_container_name']
            container_opts['name'] = host['docker_container_name']
          else
            container_opts['name'] = ['beaker', host.name, SecureRandom.uuid.split('-').last].join('-')
          end

          if host['docker_port_bindings']
            container_opts['ExposedPorts'] = {} if container_opts['ExposedPorts'].nil?
            host['docker_port_bindings'].each_pair do |port, bind|
              container_opts['ExposedPorts'][port.to_s] = {}
              container_opts['HostConfig']['PortBindings'][port.to_s] = bind
            end
          end

          ### END CONTAINER OPTIONS MANGLING ###

          @logger.debug("Creating container from image #{image_name}")

          ok=false
          retries=0
          while(!ok && (retries < 5))
            container = ::Docker::Container.create(container_opts)

            ssh_info = get_ssh_connection_info(container)
            if ::Docker.rootless? && ssh_info[:ip] == '127.0.0.1' && (ssh_info[:port].to_i < 1024)
              @logger.debug("#{host} was given a port less than 1024 but you are connecting to a rootless instance, retrying")

              container.delete(force: true)
              container = nil

              retries+=1
              next
            end

            ok=true
          end
        else
          host['use_existing_container'] = true
        end

        if container.nil?
          raise RuntimeError, 'Cannot continue because no existing container ' +
                              'could be found and provisioning is disabled.'
        end

        fix_ssh(container) if @options[:provision] == false

        @logger.debug("Starting container #{container.id}")
        container.start

        begin
          container.stats
        rescue StandardError => e
          container.delete(force: true)
          raise "Container '#{container.id}' in a bad state: #{e}"
        end

        # Preserve the ability to talk directly to the underlying API
        #
        # You can use any method defined by the docker-api gem on this object
        # https://github.com/swipely/docker-api
        host[:docker_container] = container

        if install_and_run_ssh(host)
          @logger.notify("Installing ssh components and starting ssh daemon in #{host} container")
          install_ssh_components(container, host)
          # run fixssh to configure and start the ssh service
          fix_ssh(container, host)
        end

        ssh_connection_info = get_ssh_connection_info(container)

        ip = ssh_connection_info[:ip]
        port = ssh_connection_info[:port]

        @logger.info("Using container connection at #{ip}:#{port}")

        forward_ssh_agent = @options[:forward_ssh_agent] || false

        host['ip'] = ip
        host['port'] = port
        host['ssh']  = {
          :password => root_password,
          :port => port,
          :forward_agent => forward_ssh_agent,
          :auth_methods => ['password', 'publickey', 'hostbased', 'keyboard-interactive']
        }

        @logger.debug("node available as ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@#{ip} -p #{port}")
        host['docker_container_id'] = container.id
        host['docker_image_id'] = image.id
        host['vm_ip'] = container.json["NetworkSettings"]["IPAddress"].to_s

        def host.reboot
          @logger.warn("Rebooting containers is ineffective...ignoring")
        end
      end

      hack_etc_hosts @hosts, @options
    end

    # This sideloads sshd after a container starts
    def install_ssh_components(container, host)
      case host['platform']
      when /ubuntu/, /debian/
        container.exec(%w(apt-get update))
        container.exec(%w(apt-get install -y openssh-server openssh-client))
        container.exec(%w(sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/*))
      when /cumulus/
        container.exec(%w(apt-get update))
        container.exec(%w(apt-get install -y openssh-server openssh-client))
        container.exec(%w(sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/*))
      when /el-[89]/, /fedora-(2[2-9]|3[0-9])/
        container.exec(%w(dnf clean all))
        container.exec(%w(dnf install -y sudo openssh-server openssh-clients))
        container.exec(%w(ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key))
        container.exec(%w(ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key))
        container.exec(%w(sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/*))
      when /^el-/, /centos/, /fedora/, /redhat/, /eos/
        container.exec(%w(yum clean all))
        container.exec(%w(yum install -y sudo openssh-server openssh-clients))
        container.exec(%w(ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key))
        container.exec(%w(ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key))
        container.exec(%w(sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/*))
      when /opensuse/, /sles/
        container.exec(%w(zypper -n in openssh))
        container.exec(%w(ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key))
        container.exec(%w(ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key))
        container.exec(%w(sed -ri 's/^#?UsePAM .*/UsePAM no/' /etc/ssh/sshd_config))
      when /archlinux/
        container.exec(%w(pacman --noconfirm -Sy archlinux-keyring))
        container.exec(%w(pacman --noconfirm -Syu))
        container.exec(%w(pacman -S --noconfirm openssh))
        container.exec(%w(ssh-keygen -A))
        container.exec(%w(sed -ri 's/^#?UsePAM .*/UsePAM no/' /etc/ssh/sshd_config))
        container.exec(%w(systemctl enable sshd))
      when /alpine/
        container.exec(%w(apk add --update openssh))
        container.exec(%w(ssh-keygen -A))
      else
        # TODO add more platform steps here
        raise "platform #{host['platform']} not yet supported on docker"
      end

      # Make sshd directory, set root password
      container.exec(%w(mkdir -p /var/run/sshd))
      container.exec(['/bin/sh', '-c', "echo root:#{root_password} | chpasswd"])
    end

    def cleanup
      @logger.notify "Cleaning up docker"
      @hosts.each do |host|
        # leave the container running if docker_preserve_container is set
        # setting docker_preserve_container also implies docker_preserve_image
        # is set, since you can't delete an image that's the base of a running
        # container
        unless host['docker_preserve_container']
          container = find_container(host)
          if container
            @logger.debug("stop container #{container.id}")
            begin
              container.kill
              sleep 2 # avoid a race condition where the root FS can't unmount
            rescue Excon::Errors::ClientError => e
              @logger.warn("stop of container #{container.id} failed: #{e.response.body}")
            end
            @logger.debug("delete container #{container.id}")
            begin
              container.delete(force: true)
            rescue Excon::Errors::ClientError => e
              @logger.warn("deletion of container #{container.id} failed: #{e.response.body}")
            end
          end

          # Do not remove the image if docker_preserve_image is set to true, otherwise remove it
          unless host['docker_preserve_image']
            image_id = host['docker_image_id']

            if image_id
              @logger.debug("deleting image #{image_id}")
              begin
                ::Docker::Image.remove(image_id)
              rescue Excon::Errors::ClientError => e
                @logger.warn("deletion of image #{image_id} failed: #{e.response.body}")
              rescue ::Docker::Error::DockerError => e
                @logger.warn("deletion of image #{image_id} caused internal Docker error: #{e.message}")
              end
            else
              @logger.warn("Intended to delete the host's docker image, but host['docker_image_id'] was not set")
            end
          end
        end
      end
    end

    private

    def root_password
      'root'
    end

    def buildargs_for(host)
      docker_buildargs = {}
      docker_buildargs_env = ENV['DOCKER_BUILDARGS']
      if docker_buildargs_env != nil
        docker_buildargs_env.split(/ +|\t+/).each do |arg|
          key,value=arg.split(/=/)
          if key
            docker_buildargs[key]=value
          else
            @logger.warn("DOCKER_BUILDARGS environment variable appears invalid, no key found for value #{value}" )
          end
        end
      end
      if docker_buildargs.empty?
        buildargs = host['docker_buildargs'] || {}
      else
        buildargs = docker_buildargs
      end
      @logger.debug("Docker build buildargs: #{buildargs}")
      JSON.generate(buildargs)
    end

    def dockerfile_for(host)
      # specify base image
      dockerfile = <<-EOF
        FROM #{host['image']}
        ENV container docker
      EOF

      # additional options to specify to the sshd
      # may vary by platform
      sshd_options = ''

      # add platform-specific actions
      service_name = "sshd"
      additional_packages = host_packages(host)
      case host['platform']
      when /ubuntu/, /debian/
        service_name = "ssh"
        dockerfile += <<~EOF
          RUN apt-get update
          RUN apt-get install -y openssh-server openssh-client #{additional_packages.join(' ')}
          RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/*
          EOF
      when  /cumulus/
          dockerfile += <<~EOF
          RUN apt-get update
          RUN apt-get install -y openssh-server openssh-client #{additional_packages.join(' ')}
          EOF
      when /el-[89]/, /fedora-(2[2-9]|3)/
        dockerfile += <<~EOF
          RUN dnf clean all
          RUN dnf install -y sudo openssh-server openssh-clients #{additional_packages.join(' ')}
          RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
          RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
          RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/*
          EOF
      when /^el-/, /centos/, /fedora/, /redhat/, /eos/
        dockerfile += <<~EOF
          RUN yum clean all
          RUN yum install -y sudo openssh-server openssh-clients #{additional_packages.join(' ')}
          RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
          RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
          RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/*
          EOF
      when /opensuse/, /sles/
        dockerfile += <<~EOF
          RUN zypper -n in openssh #{additional_packages.join(' ')}
          RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
          RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
          RUN sed -ri 's/^#?UsePAM .*/UsePAM no/' /etc/ssh/sshd_config
          RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/*
          EOF
      when /archlinux/
        dockerfile += <<~EOF
          RUN pacman --sync --refresh --noconfirm archlinux-keyring
          RUN pacman --sync --refresh --noconfirm --sysupgrade
          RUN pacman --sync --noconfirm #{additional_packages.join(' ')}
          RUN ssh-keygen -A
          RUN sed -ri 's/^#?UsePAM .*/UsePAM no/' /etc/ssh/sshd_config
          RUN systemctl enable sshd
          EOF
      else
        # TODO add more platform steps here
        raise "platform #{host['platform']} not yet supported on docker"
      end

      # Make sshd directory, set root password
      dockerfile += <<~EOF
        RUN mkdir -p /var/run/sshd
        RUN echo root:#{root_password} | chpasswd
        EOF

      # Configure sshd service to allowroot login using password
      # Also, disable reverse DNS lookups to prevent every. single. ssh
      # operation taking 30 seconds while the lookup times out.
      dockerfile += <<~EOF
        RUN sed -ri 's/^#?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
        RUN sed -ri 's/^#?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
        RUN sed -ri 's/^#?UseDNS .*/UseDNS no/' /etc/ssh/sshd_config
        EOF


      # Any extra commands specified for the host
      dockerfile += (host['docker_image_commands'] || []).map { |command|
        "RUN #{command}\n"
      }.join('')

      # Override image entrypoint
      if host['docker_image_entrypoint']
        dockerfile += "ENTRYPOINT #{host['docker_image_entrypoint']}\n"
      end

      # How to start a sshd on port 22.  May be an init for more supervision
      # Ensure that the ssh server can be restarted (done from set_env) and container keeps running
      cmd = host['docker_cmd'] || ["sh","-c","service #{service_name} start ; tail -f /dev/null"]
      dockerfile += <<-EOF
        EXPOSE 22
        CMD #{cmd}
      EOF

    # end

      @logger.debug("Dockerfile is #{dockerfile}")
      return dockerfile
    end

    # a puppet run may have changed the ssh config which would
    # keep us out of the container.  This is a best effort to fix it.
    # Optionally pass in a host object to to determine which ssh
    # restart command we should try.
    def fix_ssh(container, host=nil)
      @logger.debug("Fixing ssh on container #{container.id}")
      container.exec(['sed','-ri',
                      's/^#?PermitRootLogin .*/PermitRootLogin yes/',
                      '/etc/ssh/sshd_config'])
      container.exec(['sed','-ri',
                      's/^#?PasswordAuthentication .*/PasswordAuthentication yes/',
                      '/etc/ssh/sshd_config'])
      container.exec(['sed','-ri',
                      's/^#?UseDNS .*/UseDNS no/',
                      '/etc/ssh/sshd_config'])
      # Make sure users with a bunch of SSH keys loaded in their keyring can
      # still run tests
      container.exec(['sed','-ri',
                     's/^#?MaxAuthTries.*/MaxAuthTries 1000/',
                     '/etc/ssh/sshd_config'])

      if host
        if host['platform'] =~ /alpine/
          container.exec(%w(/usr/sbin/sshd))
        else
          container.exec(%w(service ssh restart))
        end
      end
    end


    # return the existing container if we're not provisioning
    # and docker_container_name is set
    def find_container(host)
      id = host['docker_container_id']
      name = host['docker_container_name']
      return unless id || name

      containers = ::Docker::Container.all

      if id
        @logger.debug("Looking for an existing container with ID #{id}")
        container = containers.select { |c| c.id == id }.first
      end

      if name && container.nil?
        @logger.debug("Looking for an existing container with name #{name}")
        container = containers.select do |c|
          c.info['Names'].include? "/#{name}"
        end.first
      end

      return container unless container.nil?
      @logger.debug("Existing container not found")
      return nil
    end

    # return true if we are inside a docker container
    def in_container?
      return File.file?('/.dockerenv')
    end

  end
end
