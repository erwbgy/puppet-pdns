require 'spec_helper'

describe 'pdns::resolver', :type => 'class' do
  let(:facts) { {
    :ipaddress => '127.0.0.1',
    :osfamily  => 'RedHat'
  } }
  context 'no parameters' do
    let(:params) { { }  }
    it {
      should create_class('pdns::resolver::config').with( {
        'listen_address' => '127.0.0.1',
        'dont_query'     => '192.168.0.0/16, 172.16.0.0/12, ::1/128',
        'forward_zones'  => nil,
        'use_hiera'      => nil
      } )
      should create_class('pdns::resolver::install')
      should create_class('pdns::resolver::service')
    }
  end
end
