# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'beaker-docker/version'

Gem::Specification.new do |s|
  s.name        = 'beaker-docker'
  s.version     = BeakerDocker::VERSION
  s.authors     = [
    'Vox Pupuli',
    'Rishi Javia',
    'Kevin Imber',
    'Tony Vu',
  ]
  s.email       = ['voxpupuli@groups.io']
  s.homepage    = 'https://github.com/voxpupuli/beaker-docker'
  s.summary     = 'Docker hypervisor for Beaker acceptance testing framework'
  s.description = 'Allows running Beaker tests using Docker'
  s.license     = 'Apache-2.0'

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.7', '< 4'

  # Testing dependencies
  s.add_development_dependency 'fakefs', '>= 1.3', '< 3.0'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'voxpupuli-rubocop', '~> 3.0.0'

  # Run time dependencies
  s.add_dependency 'beaker', '>= 4', '< 7'
  s.add_dependency 'docker-api', '~> 2.3'
  s.add_dependency 'stringify-hash', '~> 0.0.0'
end
