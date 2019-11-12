# beaker-docker

Beaker library to use docker hypervisor

# How to use this wizardry

This gem that allows you to use hosts with [docker](docker.md) hypervisor with [beaker](https://github.com/puppetlabs/beaker).

Beaker will automatically load the appropriate hypervisors for any given hosts file, so as long as your project dependencies are satisfied there's nothing else to do. No need to `require` this library in your tests.

## With Beaker 3.x

This library is included as a dependency of Beaker 3.x versions, so there's nothing to do.

## With Beaker 4.x

As of Beaker 4.0, all hypervisor and DSL extension libraries have been removed and are no longer dependencies. In order to use a specific hypervisor or DSL extension library in your project, you will need to include them alongside Beaker in your Gemfile or project.gemspec. E.g.

~~~ruby
# Gemfile
gem 'beaker', '~>4.0'
gem 'beaker-aws'
# project.gemspec
s.add_runtime_dependency 'beaker', '~>4.0'
s.add_runtime_dependency 'beaker-aws'
~~~

# Spec tests

Spec test live under the `spec` folder. There are the default rake task and therefore can run with a simple command:
```bash
bundle exec rake test:spec
```

# Acceptance tests

There is a simple rake task to invoke acceptance test for the library: 
```bash
bundle exec rake test:acceptance
```

# Contributing

Please refer to puppetlabs/beaker's [contributing](https://github.com/puppetlabs/beaker/blob/master/CONTRIBUTING.md) guide.

# Releasing

To release new versions of beaker-docker, please use this [jenkins job](https://cinext-jenkinsmaster-sre-prod-1.delivery.puppetlabs.net/view/all/job/qe_beaker-docker_init-multijob_master/). This job
lives on Puppet-internal infrastructure, so you'll need to be a part of the Puppet org to do this.

To run the job, click on `Build with Parameters` in the menu on the left. Make
sure you check the box next to `PUBLIC` and enter the appropriate version. The
version should adhere to [semantic version standards](https://semver.org).
When in doubt, consult the [maintainers of Beaker](https://github.com/puppetlabs/beaker/blob/master/CODEOWNERS)
for guidance.
