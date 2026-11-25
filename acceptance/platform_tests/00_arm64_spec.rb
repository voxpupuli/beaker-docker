# frozen_string_literal: true

require 'beaker'
require 'docker'

test_name 'Provision an ARM64 container on an AMD64 host' do
  hosts.each do |host|
    step "Verify the image used by #{host} is ARM64" do
      image_id = host[:docker_container].json.fetch('Image')
      # Beaker evaluates this file in its own namespace, which also defines Docker.
      image = ::Docker::Image.get(image_id).json # rubocop:disable Style/RedundantConstantBase
      assert_equal('linux', image.fetch('Os'))
      assert_equal('arm64', image.fetch('Architecture'))
    end

    step "Verify ARM64 binaries run on #{host}" do
      assert_equal('arm64', on(host, 'dpkg --print-architecture').stdout.strip)
      assert_equal('aarch64', on(host, 'uname -m').stdout.strip)
    end
  end
end
