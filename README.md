# beaker-docker

[![License](https://img.shields.io/github/license/voxpupuli/beaker-docker.svg)](https://github.com/voxpupuli/beaker-docker/blob/master/LICENSE)
[![Test](https://github.com/voxpupuli/beaker-docker/actions/workflows/test.yml/badge.svg)](https://github.com/voxpupuli/beaker-docker/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/voxpupuli/beaker-docker/branch/master/graph/badge.svg?token=Mypkl78hvK)](https://codecov.io/gh/voxpupuli/beaker-docker)
[![Release](https://github.com/voxpupuli/beaker-docker/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/beaker-docker/actions/workflows/release.yml)
[![RubyGem Version](https://img.shields.io/gem/v/beaker-docker.svg)](https://rubygems.org/gems/beaker-docker)
[![RubyGem Downloads](https://img.shields.io/gem/dt/beaker-docker.svg)](https://rubygems.org/gems/beaker-docker)
[![Donated by Puppet Inc](https://img.shields.io/badge/donated%20by-Puppet%20Inc-fb7047.svg)](#transfer-notice)

Beaker library to use docker hypervisor

* [How to use this wizardry](#how-to-use-this-wizardry)
  * [Nodeset Options](#nodeset-options)
  * [Privileged containers](#privileged-containers)
  * [Cleaning up after tests](#cleaning-up-after-tests)
* [Working with `podman`](#working-with-podman)
* [Generating a Dockerfile](#generating-a-dockerfile)
* [Spec tests]()
* [Acceptance tests]()
* [Transfer Notice](#transfer-notice)
* [License](#license)
* [Release Information](#release-information)

## How to use this wizardry

This gem that allows you to use hosts with [docker](docker.md) hypervisor with [beaker](https://github.com/voxpupuli/beaker).

Beaker will automatically load the appropriate hypervisors for any given hosts
file, so as long as your project dependencies are satisfied there's nothing else
to do. No need to `require` this library in your tests.

In order to use a specific hypervisor or DSL extension library in your project,
you will need to include them alongside Beaker in your Gemfile or
project.gemspec. E.g.

```ruby
# Gemfile
gem 'beaker', '~> 4.0'
gem 'beaker-docker'
# project.gemspec
s.add_runtime_dependency 'beaker', '~> 4.0'
s.add_runtime_dependency 'beaker-docker'
```

### Nodeset Options

The following is a sample nodeset:

```yaml
HOSTS:
  el8:
    platform: el-8-x86_64
    hypervisor: docker
    image: centos:8
    docker_cmd: '["/sbin/init"]'
    # Run arbitrary things
    docker_image_commands:
      - 'touch /tmp/myfile'
    dockeropts:
      Labels:
        thing: 'stuff'
      HostConfig:
        Privileged: true
  el7:
    platform: el-7-x86_64
    hypervisor: docker
    image: centos:7
    # EL7 images do not support nested systemd
    docker_cmd: '/usr/sbin/sshd -D -E /var/log/sshd.log'
CONFIG:
  docker_cap_add:
    - AUDIT_WRITE
```

### Privileged containers

Containers are run in privileged mode by default unless capabilities are set.

If you wish to disable privileged mode, simply set the following in your node:

```yaml
dockeropts:
  HostConfig:
    Privileged: false
```

### Cleaning up after tests

Containers created by this plugin may not be destroyed unless the tests complete
successfully. Each container created is prefixed by `beaker-` to make filtering
for clean up easier.

A quick way to clean up all nodes is as follows:

```sh
podman rm -f $( podman ps -q -f name="beaker-*" )
```

## Working with `podman`

If you're using a version of `podman` that has API socket support then you
should be able to simply set `DOCKER_HOST` to your socket and connect as usual.

You also need to ensure that you're using a version of the `docker-api` gem that
supports `podman`.

You may find that not all of your tests work as expected. This will be due to
the tighter system restrictions placed on containers by `podman`. You may need
to edit the `dockeropts` hash in your nodeset to include different flags in the
`HostConfig` section.

See the
[HostConfig](https://any-api.com/docker_com/engine/docs/Definitions/HostConfig)
portion of the docker API for more information.

## Generating a Dockerfile

Usually beaker-docker is used to provision docker instances with beaker. During
this step beaker-docker generates a Dockerfile and posts it to the docker daemon
API.

There's also a small CLI command to only generate the file:

```
bundle exec beaker-docker dockerfile archlinux-64
```

Will generate a local `Dockerfile`:

```dockerfile
FROM archlinux/archlinux
ENV container docker
RUN pacman --sync --refresh --noconfirm archlinux-keyring && pacman --sync --refresh --noconfirm --sysupgrade && pacman --sync --noconfirm curl ntp net-tools openssh && ssh-keygen -A && sed -ri 's/^#?UsePAM .*/UsePAM no/' /etc/ssh/sshd_config && systemctl enable sshd
RUN mkdir -p /var/run/sshd && echo root:root | chpasswd
RUN sed -ri -e 's/^#?PermitRootLogin .*/PermitRootLogin yes/' -e 's/^#?PasswordAuthentication .*/PasswordAuthentication yes/' -e 's/^#?UseDNS .*/UseDNS no/' -e 's/^#?MaxAuthTries.*/MaxAuthTries 1000/' /etc/ssh/sshd_config
EXPOSE 22
CMD ["/sbin/init"]
```

This works by calling
(beaker-hostgenerator](https://github.com/voxpupuli/beaker-hostgenerator?tab=readme-ov-file#beaker-host-generator).
So you can provide any host string that's supported by beaker-hostgenerator.

For non-rolling release distros this is usually `$os$majorversion-$architecture`

```
beaker-docker dockerfile centos9-64
```

```dockerfile
FROM quay.io/centos/centos:stream9
ENV container docker
RUN dnf clean all && dnf install -y sudo openssh-server openssh-clients chrony && ssh-keygen -A && sed 's@session *required *pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/*
RUN mkdir -p /var/run/sshd && echo root:root | chpasswd
RUN sed -ri -e 's/^#?PermitRootLogin .*/PermitRootLogin yes/' -e 's/^#?PasswordAuthentication .*/PasswordAuthentication yes/' -e 's/^#?UseDNS .*/UseDNS no/' -e 's/^#?MaxAuthTries.*/MaxAuthTries 1000/' /etc/ssh/sshd_config
RUN cp /bin/true /sbin/agetty
RUN dnf install -y cronie crontabs initscripts iproute openssl wget which glibc-langpack-en hostname
EXPOSE 22
CMD ["/sbin/init"]
```

This requires a running docker daemon. You can also request a containerfile.
This will currently generate a `Containerfile` but with the same content (this
may change in the future, depending on the API spec).

## Spec tests

Spec test live under the `spec` folder. There are the default rake task and therefore can run with a simple command:

```bash
bundle exec rake test:spec
```

## Acceptance tests

There is a simple rake task to invoke acceptance test for the library:

```bash
bundle exec rake test:acceptance
```

## Transfer Notice

This plugin was originally authored by [Puppet Inc](http://puppet.com).
The maintainer preferred that Puppet Community take ownership of the module for future improvement and maintenance.
Existing pull requests and issues were transferred over, please fork and continue to contribute here.

Previously: https://github.com/puppetlabs/beaker

## License

This gem is licensed under the Apache-2 license.

## Release information

To make a new release, please do:
* update the version in `lib/beaker-docker/version.rb`
* Install gems with `bundle install --with release --path .vendor`
* generate the changelog with `bundle exec rake changelog`
* Check if the new version matches the closed issues/PRs in the changelog
* Create a PR with it
* After it got merged, push a tag. GitHub actions will do the actual release to rubygems and GitHub Packages
