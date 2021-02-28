require 'beaker'
require 'beaker-rspec'

RSpec.describe 'it can connect' do
  hosts.each do |host|
    context "on #{host}" do
      on(host, 'ls /tmp')
    end
  end
end
