# frozen_string_literal: true

require 'beaker'

begin
  require 'simplecov'
  require 'simplecov-console'
  require 'codecov'
rescue LoadError
  # Do nothing if no required gem installed
else
  SimpleCov.start do
    track_files 'lib/**/*.rb'

    add_filter '/spec'
    # do not track vendored files
    add_filter '/vendor'
    add_filter '/.vendor'

    enable_coverage :branch
  end

  SimpleCov.formatters = [
    SimpleCov::Formatter::Console,
    SimpleCov::Formatter::Codecov,
  ]
end

Dir['./lib/beaker/hypervisor/*.rb'].sort.each { |file| require file }

# setup & require beaker's spec_helper.rb
beaker_gem_spec = Gem::Specification.find_by_name('beaker')
beaker_gem_dir = beaker_gem_spec.gem_dir
beaker_spec_path = File.join(beaker_gem_dir, 'spec')
$LOAD_PATH << beaker_spec_path
require File.join(beaker_spec_path, 'spec_helper.rb')

RSpec.configure do |config|
  config.include TestFileHelpers
  config.include HostHelpers
end
