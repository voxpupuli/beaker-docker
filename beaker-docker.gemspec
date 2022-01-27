# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'beaker-docker/version'

Gem::Specification.new do |s|
  s.name        = "beaker-docker"
  s.version     = BeakerDocker::VERSION
  s.authors     = [
    "Vox Pupuli",
    "Rishi Javia",
    "Kevin Imber",
    "Tony Vu"
  ]
  s.email       = ["voxpupuli@groups.io"]
  s.homepage    = "https://github.com/voxpupuli/beaker-docker"
  s.summary     = %q{Beaker DSL Extension Helpers!}
  s.description = %q{For use for the Beaker acceptance testing tool}
  s.license     = 'Apache-2.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Testing dependencies
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-its', '~> 1.3'
  s.add_development_dependency 'fakefs', '~> 1.3'
  s.add_development_dependency 'rake', '~> 13.0'

  # Run time dependencies
  s.add_runtime_dependency 'stringify-hash', '~> 0.0.0'
  s.add_runtime_dependency 'docker-api', '~> 2.1'
  s.add_runtime_dependency 'beaker', '>= 4.34'
end
