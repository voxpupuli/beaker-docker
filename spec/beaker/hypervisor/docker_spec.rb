# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module Beaker
  platforms = [
    'ubuntu-14.04-x86_64',
    'fedora-22-x86_64',
    'centos-7-x86_64',
    'sles-12-x86_64',
    'archlinux-2017.12.27-x86_64',
    'amazon-2023-x86_64',
  ]

  describe Docker do
    require 'docker'

    let(:hosts) do
      the_hosts = make_hosts
      the_hosts[2]['dockeropts'] = {
        Labels: {
          'one' => 3,
          'two' => 4,
        },
      }
      the_hosts
    end

    let(:logger) do
      logger = instance_double(Logger)
      allow(logger).to receive(:debug)
      allow(logger).to receive(:info)
      allow(logger).to receive(:warn)
      allow(logger).to receive(:error)
      allow(logger).to receive(:notify)
      logger
    end

    let(:options) do
      {
        logger: logger,
        forward_ssh_agent: true,
        provision: true,
        dockeropts: {
          Labels: {
            'one' => 1,
            'two' => 2,
          },
        },
      }
    end

    let(:image) do
      image = instance_double(::Docker::Image)
      allow(image).to receive(:id).and_return('zyxwvu')
      allow(image).to receive(:tag)
      image
    end

    let(:container_mode) do
      'rootless'
    end

    let(:container_config) do
      conf = {
        'HostConfig' => {
          'NetworkMode' => 'slirp4netns',
        },
        'NetworkSettings' => {
          'IPAddress' => '192.0.2.1',
          'Ports' => {
            '22/tcp' => [
              {
                'HostIp' => '0.0.0.0',
                'HostPort' => 8022,
              },
            ],
          },
          'Gateway' => '192.0.2.254',
        },
      }

      conf['HostConfig']['NetworkMode'] = 'bridge' unless container_mode == 'rootless'

      conf
    end

    let(:container) do
      container = instance_double(::Docker::Container)
      allow(container).to receive(:id).and_return('abcdef')
      allow(container).to receive(:start)
      allow(container).to receive(:stats)
      allow(container).to receive(:info).and_return(
        *(0..2).map { |index| { 'Names' => ["/spec-container-#{index}"] } },
      )
      allow(container).to receive(:json).and_return(container_config)
      allow(container).to receive(:kill)
      allow(container).to receive(:delete)
      allow(container).to receive(:exec)
      container
    end

    let(:docker) { ::Beaker::Docker.new(hosts, options) }

    let(:docker_options) { nil }

    let(:version) { { 'ApiVersion' => '1.18', 'Arch' => 'amd64', 'GitCommit' => '4749651', 'GoVersion' => 'go1.4.2', 'KernelVersion' => '3.16.0-37-generic', 'Os' => 'linux', 'Version' => '1.6.0' } }

    before do
      allow(::Docker).to receive(:rootless?).and_return(true)
      @docker_host = ENV.fetch('DOCKER_HOST', nil)
      ENV.delete('DOCKER_HOST') if @docker_host
    end

    after do
      ENV['DOCKER_HOST'] = @docker_host if @docker_host
    end

    context 'with connection failure' do
      describe '#initialize' do
        before do
          require 'excon'
          allow(::Docker).to receive(:version).and_raise(Excon::Errors::SocketError.new(StandardError.new('oops'))).exactly(4).times
        end

        it 'fails when docker not present' do
          expect { docker }.to raise_error(RuntimeError, /Docker instance not connectable/)
          expect { docker }.to raise_error(RuntimeError, /Check your DOCKER_HOST variable has been set/)
          expect { docker }.to raise_error(RuntimeError, /If you are on OSX or Windows, you might not have Docker Machine setup correctly/)
          expect { docker }.to raise_error(RuntimeError, /Error was: oops/)
        end
      end
    end

    context 'with a working connection' do
      before do
        # Stub out all of the docker-api gem. we should never really call it from these tests
        allow(::Docker).to receive(:options).and_return(docker_options)
        allow(::Docker).to receive(:podman?).and_return(false)
        allow(::Docker).to receive(:version).and_return(version)
        allow(::Docker::Image).to receive(:build).and_return(image)
        allow(::Docker::Image).to receive(:create).and_return(image)
        allow(::Docker::Container).to receive(:create).and_return(container)
      end

      describe '#initialize' do
        it 'sets Docker options' do
          expect(::Docker).to receive(:options=).with({ write_timeout: 300, read_timeout: 300 }).once

          docker
        end

        context 'when Docker options are already set' do
          let(:docker_options) { { write_timeout: 600, foo: :bar } }

          it 'does not override Docker options' do
            expect(::Docker).to receive(:options=).with({ write_timeout: 600, read_timeout: 300, foo: :bar }).once

            docker
          end
        end

        it 'checks the Docker gem can work with the api' do
          expect { docker }.not_to raise_error
        end

        it 'hooks the Beaker logger into the Docker one' do
          expect(::Docker).to receive(:logger=).with(logger)

          docker
        end
      end

      describe '#install_ssh_components' do
        let(:test_container) { object_double(container) }
        let(:host) { hosts[0] }

        before do
          allow(docker).to receive(:dockerfile_for)
        end

        platforms.each do |platform|
          it 'calls exec at least twice' do
            host['platform'] = platform
            expect(test_container).to receive(:exec).at_least(:twice)
            docker.install_ssh_components(test_container, host)
          end
        end

        it 'accepts alpine as valid platform' do
          host['platform'] = Beaker::Platform.new('alpine-3.8-x86_64')
          expect(test_container).to receive(:exec).at_least(:twice)
          docker.install_ssh_components(test_container, host)
        end

        it 'raises an error with an unsupported platform' do
          host['platform'] = Beaker::Platform.new('windows-11-64')
          expect { docker.install_ssh_components(test_container, host) }.to raise_error(RuntimeError, /windows/)
        end
      end

      describe '#provision' do
        before do
          allow(docker).to receive(:dockerfile_for)
        end

        context 'when the host has "tag" defined' do
          before do
            hosts.each do |host|
              host['tag'] = 'my_tag'
            end
          end

          it 'tags the image with the value of the tag' do
            expect(image).to receive(:tag).with({ repo: 'my_tag' }).exactly(3).times
            docker.provision
          end
        end

        context 'when the host has "use_image_entry_point" set to true on the host' do
          before do
            hosts.each do |host|
              host['use_image_entry_point'] = true
            end
          end

          it 'does not call #dockerfile_for but run methods necessary for ssh installation' do
            expect(docker).not_to receive(:dockerfile_for)
            expect(docker).to receive(:install_ssh_components).exactly(3).times # once per host
            expect(docker).to receive(:fix_ssh).exactly(3).times # once per host
            docker.provision
          end
        end

        context 'when the host has a "dockerfile" for the host' do
          before do
            allow(docker).to receive(:buildargs_for).and_return('buildargs')
            hosts.each do |host|
              host['dockerfile'] = 'mydockerfile'
            end
          end

          it 'does not call #dockerfile_for but run methods necessary for ssh installation' do
            allow(File).to receive(:exist?).with('mydockerfile').and_return(true)
            allow(::Docker::Image).to receive(:build_from_dir).with('/', hash_including(rm: true, buildargs: 'buildargs')).and_return(image)
            expect(docker).not_to receive(:dockerfile_for)
            expect(docker).to receive(:install_ssh_components).exactly(3).times # once per host
            expect(docker).to receive(:fix_ssh).exactly(3).times # once per host
            docker.provision
          end
        end

        it 'calls image create for hosts when use_image_as_is is defined' do
          hosts.each do |host|
            host['use_image_as_is'] = true
            expect(docker).not_to receive(:install_ssh_components)
            expect(docker).not_to receive(:fix_ssh)
            expect(::Docker::Image).to receive(:create).with('fromImage' => host['image']) # once per host
            expect(::Docker::Image).not_to receive(:build)
            expect(::Docker::Image).not_to receive(:build_from_dir)
          end

          docker.provision
        end

        it 'calls dockerfile_for with all the hosts' do
          hosts.each do |host|
            allow(docker).to receive(:dockerfile_for).with(host).and_return('')
            expect(docker).not_to receive(:install_ssh_components)
            expect(docker).not_to receive(:fix_ssh)
            expect(docker).to receive(:dockerfile_for).with(host)
          end

          docker.provision
        end

        it 'passes the Dockerfile on to Docker::Image.create' do
          allow(docker).to receive(:dockerfile_for).and_return('special testing value')
          expect(::Docker::Image).to receive(:build).with('special testing value', { rm: true, buildargs: '{}' })

          docker.provision
        end

        it 'passes the buildargs from ENV DOCKER_BUILDARGS on to Docker::Image.create' do
          allow(docker).to receive(:dockerfile_for).and_return('special testing value')
          ENV['DOCKER_BUILDARGS'] = 'HTTP_PROXY=http://1.1.1.1:3128'
          expect(::Docker::Image).to receive(:build).with('special testing value', { rm: true, buildargs: '{"HTTP_PROXY":"http://1.1.1.1:3128"}' })

          docker.provision
        end

        it 'passes the multiple buildargs from ENV DOCKER_BUILDARGS on to Docker::Image.create' do
          allow(docker).to receive(:dockerfile_for).and_return('special testing value')
          ENV['DOCKER_BUILDARGS'] = 'HTTP_PROXY=http://1.1.1.1:3128	HTTPS_PROXY=https://1.1.1.1:3129'
          expect(::Docker::Image).to receive(:build).with('special testing value', { rm: true, buildargs: '{"HTTP_PROXY":"http://1.1.1.1:3128","HTTPS_PROXY":"https://1.1.1.1:3129"}' })

          docker.provision
        end

        it 'creates a container with correct image and hostname' do
          hosts.each_with_index do |host, _index|
            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:Image]).to eq(image.id)
              expect(args[:Hostname]).to eq(host.name)
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a container with correct host config settings' do
          hosts.each_with_index do |_host, _index|
            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:HostConfig][:PublishAllPorts]).to be true
              expect(args[:HostConfig][:Privileged]).to be true
              expect(args[:HostConfig][:RestartPolicy][:Name]).to eq('always')
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a container with correct port bindings' do
          hosts.each_with_index do |_host, _index|
            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:HostConfig][:PortBindings]['22/tcp'][0]['HostPort']).to be_a(String)
              expect(args[:HostConfig][:PortBindings]['22/tcp'][0]['HostIp']).to eq('0.0.0.0')
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a container with correct labels and name' do
          hosts.each_with_index do |_host, index|
            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:Labels][:one]).to eq(((index == 2) ? 3 : 1))
              expect(args[:Labels][:two]).to eq(((index == 2) ? 4 : 2))
              expect(args[:name]).to match(/\Abeaker-/)
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a named container with correct basic properties' do
          hosts.each_with_index do |host, index|
            container_name = "spec-container-#{index}"
            host['docker_container_name'] = container_name

            allow(::Docker::Container).to receive(:all).and_return([])
            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:Image]).to eq(image.id)
              expect(args[:Hostname]).to eq(host.name)
              expect(args[:name]).to eq(container_name)
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a named container with correct host config' do
          hosts.each_with_index do |host, index|
            container_name = "spec-container-#{index}"
            host['docker_container_name'] = container_name

            allow(::Docker::Container).to receive(:all).and_return([])
            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:HostConfig][:PublishAllPorts]).to be true
              expect(args[:HostConfig][:Privileged]).to be true
              expect(args[:HostConfig][:RestartPolicy][:Name]).to eq('always')
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a named container with correct port bindings and labels' do
          hosts.each_with_index do |host, index|
            container_name = "spec-container-#{index}"
            host['docker_container_name'] = container_name

            allow(::Docker::Container).to receive(:all).and_return([])
            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:HostConfig][:PortBindings]['22/tcp'][0]['HostPort']).to be_a(String)
              expect(args[:HostConfig][:PortBindings]['22/tcp'][0]['HostIp']).to eq('0.0.0.0')
              expect(args[:Labels][:one]).to eq(((index == 2) ? 3 : 1))
              expect(args[:Labels][:two]).to eq(((index == 2) ? 4 : 2))
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a container with volumes bound' do
          hosts.each_with_index do |host, _index|
            host['mount_folders'] = {
              'mount1' => {
                'host_path' => '/source_folder',
                'container_path' => '/mount_point',
              },
              'mount2' => {
                'host_path' => '/another_folder',
                'container_path' => '/another_mount',
                'opts' => 'ro',
              },
              'mount3' => {
                'host_path' => '/different_folder',
                'container_path' => '/different_mount',
                'opts' => 'rw',
              },
              'mount4' => {
                'host_path' => './',
                'container_path' => '/relative_mount',
              },
              'mount5' => {
                'host_path' => 'local_folder',
                'container_path' => '/another_relative_mount',
              },
            }

            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:HostConfig][:Binds]).to eq([
                                                        '/source_folder:/mount_point:z',
                                                        '/another_folder:/another_mount:ro',
                                                        '/different_folder:/different_mount:rw',
                                                        "#{File.expand_path('./')}:/relative_mount:z",
                                                        "#{File.expand_path('local_folder')}:/another_relative_mount:z",
                                                      ])
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a volume container with correct image and hostname' do
          hosts.each_with_index do |host, _index|
            host['mount_folders'] = {
              'mount1' => {
                'host_path' => '/source_folder',
                'container_path' => '/mount_point',
              },
            }

            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:Image]).to eq(image.id)
              expect(args[:Hostname]).to eq(host.name)
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a volume container with correct labels and name' do
          hosts.each_with_index do |host, index|
            host['mount_folders'] = {
              'mount1' => {
                'host_path' => '/source_folder',
                'container_path' => '/mount_point',
              },
            }

            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:Labels][:one]).to eq(((index == 2) ? 3 : 1))
              expect(args[:Labels][:two]).to eq(((index == 2) ? 4 : 2))
              expect(args[:name]).to match(/\Abeaker-/)
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a volume container with correct port bindings' do
          hosts.each_with_index do |host, _index|
            host['mount_folders'] = {
              'mount1' => {
                'host_path' => '/source_folder',
                'container_path' => '/mount_point',
              },
            }

            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:HostConfig][:PortBindings]['22/tcp'][0]['HostPort']).to be_a(String)
              expect(args[:HostConfig][:PortBindings]['22/tcp'][0]['HostIp']).to eq('0.0.0.0')
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a volume container with correct container settings' do
          hosts.each_with_index do |host, _index|
            host['mount_folders'] = {
              'mount1' => {
                'host_path' => '/source_folder',
                'container_path' => '/mount_point',
              },
            }

            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:HostConfig][:PublishAllPorts]).to be true
              expect(args[:HostConfig][:Privileged]).to be true
              expect(args[:HostConfig][:RestartPolicy][:Name]).to eq('always')
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a container with capabilities added' do
          hosts.each_with_index do |host, _index|
            host['docker_cap_add'] = %w[NET_ADMIN SYS_ADMIN]

            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:HostConfig][:CapAdd]).to eq(%w[NET_ADMIN SYS_ADMIN])
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a cap container with correct image and hostname' do
          hosts.each_with_index do |host, _index|
            host['docker_cap_add'] = %w[NET_ADMIN SYS_ADMIN]

            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:Image]).to eq(image.id)
              expect(args[:Hostname]).to eq(host.name)
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a cap container with correct labels and name' do
          hosts.each_with_index do |host, index|
            host['docker_cap_add'] = %w[NET_ADMIN SYS_ADMIN]

            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:Labels][:one]).to eq(((index == 2) ? 3 : 1))
              expect(args[:Labels][:two]).to eq(((index == 2) ? 4 : 2))
              expect(args[:name]).to match(/\Abeaker-/)
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a cap container with correct host config' do
          hosts.each_with_index do |host, _index|
            host['docker_cap_add'] = %w[NET_ADMIN SYS_ADMIN]

            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:HostConfig][:PortBindings]['22/tcp'][0]['HostPort']).to be_a(String)
              expect(args[:HostConfig][:PortBindings]['22/tcp'][0]['HostIp']).to eq('0.0.0.0')
              expect(args[:HostConfig][:PublishAllPorts]).to be true
              expect(args[:HostConfig][:RestartPolicy][:Name]).to eq('always')
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a container with port bindings' do
          hosts.each_with_index do |host, _index|
            host['docker_port_bindings'] = {
              '8080/tcp' => [{ 'HostPort' => '8080', 'HostIp' => '0.0.0.0' }],
            }

            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:ExposedPorts]).to eq({ '8080/tcp' => {} })
              expect(args[:HostConfig][:PortBindings]['8080/tcp']).to eq([{ 'HostPort' => '8080', 'HostIp' => '0.0.0.0' }])
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a port binding container with correct image and hostname' do
          hosts.each_with_index do |host, _index|
            host['docker_port_bindings'] = {
              '8080/tcp' => [{ 'HostPort' => '8080', 'HostIp' => '0.0.0.0' }],
            }

            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:Image]).to eq(image.id)
              expect(args[:Hostname]).to eq(host.name)
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a port binding container with correct labels and name' do
          hosts.each_with_index do |host, index|
            host['docker_port_bindings'] = {
              '8080/tcp' => [{ 'HostPort' => '8080', 'HostIp' => '0.0.0.0' }],
            }

            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:Labels][:one]).to eq(((index == 2) ? 3 : 1))
              expect(args[:Labels][:two]).to eq(((index == 2) ? 4 : 2))
              expect(args[:name]).to match(/\Abeaker-/)
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a port binding container with correct port bindings' do
          hosts.each_with_index do |host, _index|
            host['docker_port_bindings'] = {
              '8080/tcp' => [{ 'HostPort' => '8080', 'HostIp' => '0.0.0.0' }],
            }

            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:HostConfig][:PortBindings]['22/tcp'][0]['HostPort']).to be_a(String)
              expect(args[:HostConfig][:PortBindings]['22/tcp'][0]['HostIp']).to eq('0.0.0.0')
            end.and_return(container)
          end

          docker.provision
        end

        it 'creates a port binding container with correct container settings' do
          hosts.each_with_index do |host, _index|
            host['docker_port_bindings'] = {
              '8080/tcp' => [{ 'HostPort' => '8080', 'HostIp' => '0.0.0.0' }],
            }

            expect(::Docker::Container).to receive(:create) do |args|
              expect(args[:HostConfig][:PublishAllPorts]).to be true
              expect(args[:HostConfig][:Privileged]).to be true
              expect(args[:HostConfig][:RestartPolicy][:Name]).to eq('always')
            end.and_return(container)
          end

          docker.provision
        end

        it 'starts the container' do
          expect(container).to receive(:start)

          docker.provision
        end

        context 'when connecting to ssh' do
          %w[rootless privileged].each do |mode|
            context "when #{mode}" do
              let(:container_mode) do
                mode
              end

              it 'exposes port 22 to beaker' do
                docker.provision

                expect(hosts[0]['ip']).to eq '127.0.0.1'
                expect(hosts[0]['port']).to eq 8022
              end

              it 'exposes port 22 to beaker when using DOCKER_HOST' do
                ENV['DOCKER_HOST'] = 'tcp://192.0.2.2:2375'
                docker.provision

                expect(hosts[0]['ip']).to eq '192.0.2.2'
                expect(hosts[0]['port']).to eq 8022
              end

              it 'has ssh agent forwarding enabled' do
                docker.provision

                expect(hosts[0]['ip']).to eq '127.0.0.1'
                expect(hosts[0]['port']).to eq 8022
                expect(hosts[0]['ssh'][:password]).to eq 'root'
                expect(hosts[0]['ssh'][:port]).to eq 8022
                expect(hosts[0]['ssh'][:forward_agent]).to be true
              end

              it 'connects to gateway ip' do
                FakeFS do
                  FileUtils.touch('/.dockerenv')
                  docker.provision

                  expect(hosts[0]['ip']).to eq '192.0.2.254'
                  expect(hosts[0]['port']).to eq 8022
                end
              end
            end
          end

          context 'when IPAddress is empty but available in Networks' do
            let(:container_config) do
              {
                'HostConfig' => {
                  'NetworkMode' => 'bridge',
                },
                'NetworkSettings' => {
                  'IPAddress' => '',
                  'Ports' => {
                    '22/tcp' => [
                      {
                        'HostIp' => '0.0.0.0',
                        'HostPort' => 8022,
                      },
                    ],
                  },
                  'Gateway' => '192.0.2.254',
                  'Networks' => {
                    'bridge' => {
                      'IPAddress' => '192.0.2.10',
                    },
                  },
                },
              }
            end

            it 'falls back to Networks[NetworkMode][IPAddress]' do
              ENV['DOCKER_IN_DOCKER'] = 'true'
              FakeFS do
                FileUtils.touch('/.dockerenv')
                docker.provision

                expect(hosts[0]['ip']).to eq '192.0.2.10'
                expect(hosts[0]['port']).to eq 22
              end
            end
          end
        end

        it 'generates a new /etc/hosts file referencing each host' do
          ENV['DOCKER_HOST'] = nil
          docker.provision
          hosts.each do |host|
            allow(docker).to receive(:get_domain_name).with(host).and_return('labs.lan')
            etc_hosts = <<~HOSTS
              127.0.0.1\tlocalhost localhost.localdomain
              192.0.2.1\tvm1.labs.lan vm1
              192.0.2.1\tvm2.labs.lan vm2
              192.0.2.1\tvm3.labs.lan vm3
            HOSTS
            expect(docker).to receive(:set_etc_hosts).with(host, etc_hosts).once
          end
          docker.hack_etc_hosts(hosts, options)
        end

        it 'records the image and container for later' do
          docker.provision

          expect(hosts[0]['docker_image_id']).to eq image.id
          expect(hosts[0]['docker_container_id']).to eq container.id
        end

        context 'when provision=false' do
          let(:options) do
            {
              logger: logger,
              forward_ssh_agent: true,
              provision: false,
            }
          end

          it 'fixes ssh' do
            hosts.each_with_index do |host, index|
              container_name = "spec-container-#{index}"
              host['docker_container_name'] = container_name

              allow(::Docker::Container).to receive(:all).and_return([container])
              expect(docker).to receive(:fix_ssh).once
            end
            docker.provision
          end

          it 'does not create a container if a named one already exists' do
            hosts.each_with_index do |host, index|
              container_name = "spec-container-#{index}"
              host['docker_container_name'] = container_name

              allow(::Docker::Container).to receive(:all).and_return([container])
              expect(::Docker::Container).not_to receive(:create)
            end

            docker.provision
          end
        end
      end

      describe '#cleanup' do
        before do
          # get into a state where there's something to clean
          allow(::Docker::Container).to receive(:all).and_return([container])
          allow(::Docker::Image).to receive(:remove).with(image.id)
          allow(docker).to receive(:dockerfile_for)
          docker.provision
        end

        it 'stops the containers' do
          allow(docker).to receive(:sleep).and_return(true)
          expect(container).to receive(:kill)
          docker.cleanup
        end

        it 'deletes the containers' do
          allow(docker).to receive(:sleep).and_return(true)
          expect(container).to receive(:delete)
          docker.cleanup
        end

        it 'deletes the images' do
          allow(docker).to receive(:sleep).and_return(true)
          expect(::Docker::Image).to receive(:remove).with(image.id)
          docker.cleanup
        end

        it 'does not delete the image if docker_preserve_image is set to true' do
          allow(docker).to receive(:sleep).and_return(true)
          hosts.each do |host|
            host['docker_preserve_image'] = true
          end
          expect(::Docker::Image).not_to receive(:remove)
          docker.cleanup
        end

        it 'deletes the image if docker_preserve_image is set to false' do
          allow(docker).to receive(:sleep).and_return(true)
          hosts.each do |host|
            host['docker_preserve_image'] = false
          end
          expect(::Docker::Image).to receive(:remove).with(image.id)
          docker.cleanup
        end
      end

      describe '#dockerfile_for' do
        FakeFS.deactivate!
        it 'raises on an unsupported platform' do
          expect { docker.send(:dockerfile_for, make_host('none', { 'platform' => 'solaris-11-64', 'image' => 'foobar' })) }.to raise_error(/platform solaris-11-64 not yet supported/)
        end

        it 'sets "ENV container docker"' do
          FakeFS.deactivate!
          platforms.each do |platform|
            dockerfile = docker.send(:dockerfile_for, make_host('none', {
                                                                  'platform' => platform,
                                                                  'image' => 'foobar',
                                                                }))
            expect(dockerfile).to match(/ENV container docker/)
          end
        end

        it 'adds docker_image_first_commands as RUN statements' do
          FakeFS.deactivate!
          platforms.each do |platform|
            dockerfile = docker.send(:dockerfile_for, make_host('none', {
                                                                  'platform' => platform,
                                                                  'image' => 'foobar',
                                                                  'docker_image_first_commands' => [
                                                                    'special one',
                                                                    'special two',
                                                                    'special three',
                                                                  ],
                                                                }))

            expect(dockerfile).to match(/RUN special one\nRUN special two\nRUN special three/)
          end
        end

        it 'adds docker_image_commands as RUN statements' do
          FakeFS.deactivate!
          platforms.each do |platform|
            dockerfile = docker.send(:dockerfile_for, make_host('none', {
                                                                  'platform' => platform,
                                                                  'image' => 'foobar',
                                                                  'docker_image_commands' => [
                                                                    'special one',
                                                                    'special two',
                                                                    'special three',
                                                                  ],
                                                                }))

            expect(dockerfile).to match(/RUN special one\nRUN special two\nRUN special three/)
          end
        end

        it 'adds docker_image_entrypoint' do
          FakeFS.deactivate!
          platforms.each do |platform|
            dockerfile = docker.send(:dockerfile_for, make_host('none', {
                                                                  'platform' => platform,
                                                                  'image' => 'foobar',
                                                                  'docker_image_entrypoint' => '/bin/bash',
                                                                }))

            expect(dockerfile).to match(%r{ENTRYPOINT /bin/bash})
          end
        end

        it 'uses zypper on sles' do
          FakeFS.deactivate!
          dockerfile = docker.send(:dockerfile_for, make_host('none', {
                                                                'platform' => Beaker::Platform.new('sles-12-x86_64'),
                                                                'image' => 'foobar',
                                                              }))

          expect(dockerfile).to match(/zypper -n in openssh/)
        end

        (22..39).to_a.each do |fedora_release|
          it "uses dnf on fedora #{fedora_release}" do
            FakeFS.deactivate!
            dockerfile = docker.send(:dockerfile_for, make_host('none', {
                                                                  'platform' => Beaker::Platform.new("fedora-#{fedora_release}-x86_64"),
                                                                  'image' => 'foobar',
                                                                }))

            expect(dockerfile).to match(/dnf install -y sudo/)
          end
        end

        it 'uses pacman on archlinux' do
          FakeFS.deactivate!
          dockerfile = docker.send(:dockerfile_for, make_host('none', {
                                                                'platform' => Beaker::Platform.new('archlinux-current-x86_64'),
                                                                'image' => 'foobar',
                                                              }))

          expect(dockerfile).to match(/pacman --sync --refresh --noconfirm archlinux-keyring/)
          expect(dockerfile).to match(/pacman --sync --refresh --noconfirm --sysupgrade/)
          expect(dockerfile).to match(/pacman --sync --noconfirm curl net-tools openssh/)
        end
      end

      describe '#fix_ssh' do
        let(:test_container) { object_double(container) }
        let(:host) { hosts[0] }

        before do
          allow(test_container).to receive(:id).and_return('abcdef')
        end

        it 'calls exec once when called without host' do
          expect(test_container).to receive(:exec).once.with(
            include(/PermitRootLogin/) &&
            include(/PasswordAuthentication/) &&
            include(/UseDNS/) &&
            include(/MaxAuthTries/),
          )
          docker.send(:fix_ssh, test_container)
        end

        it 'execs sshd on alpine' do
          host['platform'] = Beaker::Platform.new('alpine-3.8-x86_64')
          expect(test_container).to receive(:exec).with(array_including('sed'))
          expect(test_container).to receive(:exec).with(%w[/usr/sbin/sshd])
          docker.send(:fix_ssh, test_container, host)
        end

        it 'restarts ssh service on ubuntu' do
          host['platform'] = Beaker::Platform.new('ubuntu-20.04-x86_64')
          expect(test_container).to receive(:exec).with(array_including('sed'))
          expect(test_container).to receive(:exec).with(%w[service ssh restart])
          docker.send(:fix_ssh, test_container, host)
        end

        it 'restarts sshd service otherwise' do
          host['platform'] = Beaker::Platform.new('centos-6-x86_64')
          expect(test_container).to receive(:exec).with(array_including('sed'))
          expect(test_container).to receive(:exec).with(%w[service sshd restart])
          docker.send(:fix_ssh, test_container, host)
        end
      end
    end
  end
end
