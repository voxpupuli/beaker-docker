# frozen_string_literal: true

require 'beaker'

test_name 'Ensure docker container is accessible' do
  hosts.each do |host|
    step "on #{host}" do
      on(host, 'true')
    end
  end
end
