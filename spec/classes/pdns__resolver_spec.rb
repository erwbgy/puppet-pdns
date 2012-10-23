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
        'use_hiera'      => nil,
        'forward_domain' => nil,
        'reverse_domain' => nil
      } )
      should create_class('pdns::resolver::install')
      should create_class('pdns::resolver::service')
    }
  end
  context 'forward_domain .local' do
    let(:params) { {
      :forward_domain => 'local',
    }  }
    it {
      should create_class('pdns::resolver::config').with( {
        'listen_address' => '10.0.0.1',
        'dont_query'     => nil,
        'forward_zones'  => nil,
        'use_hiera'      => nil,
        'forward_domain' => 'local',
        'reverse_domain' => nil
      } )
      should create_class('pdns::resolver::install')
      should create_class('pdns::resolver::service')
    }
  end
  context 'listen_address' do
    let(:params) { {
      :forward_domain => 'local',
      :listen_address => '127.0.0.1',
    }  }
    it {
      should create_class('pdns::resolver::config').with( {
        'listen_address' => '127.0.0.1',
        'dont_query'     => nil,
        'forward_zones'  => nil,
        'use_hiera'      => nil,
        'forward_domain' => 'local',
        'reverse_domain' => nil
      } )
      should create_class('pdns::resolver::install')
      should create_class('pdns::resolver::service')
    }
  end
end
