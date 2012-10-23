require 'spec_helper'

describe 'pdns::resolver', :type => 'class' do
  let(:facts) { {
    :ipaddress => '10.0.0.1',
    :osfamily  => 'RedHat'
  } }
  context 'no parameters' do
    let(:params) { { }  }
    it {
      should create_class('pdns::resolver::config').with( {
        'listen_address' => '10.0.0.1',
        'dont_query'     => nil,
        'forward_zones'  => nil,
        'use_hiera'      => nil
      } )
      should create_class('pdns::resolver::install')
      should create_class('pdns::resolver::service')
    }
  end
end
