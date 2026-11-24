# frozen_string_literal: true

require 'beaker'

# Run through `rake test:acceptance:wsl` with WSLENV set. On a plain Linux
# machine the container IP on port 22 is reachable as well, so merely logging
# in proves nothing: this has to check which address and port beaker-docker
# picked.
test_name 'Explicit ssh port binding is honoured under WSL' do
  step 'WSL is being simulated' do
    assert(ENV.key?('WSLENV'), 'WSLENV is not set, this test would not exercise the WSL code path')
  end

  hosts.each do |host|
    step "on #{host}" do
      assert_equal('127.0.0.1', host['ip'].to_s, 'beaker-docker should connect through the published address')
      assert_equal('2222', host['port'].to_s, 'beaker-docker should connect through the explicitly bound port')
      on(host, 'true')
    end
  end
end
