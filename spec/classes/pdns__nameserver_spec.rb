require 'spec_helper'

describe 'pdns::nameserver', :type => 'class' do
  let(:facts) { {
    :ipaddress => '127.0.0.1',
    :osfamily  => 'RedHat'
  } }
  context 'no parameters' do
    let(:params) { { }  }
    it {
      should create_class('pdns::nameserver::config').with_backend('sqlite').with_listen_address('127.0.0.1')
      should create_class('pdns::nameserver::install').with_backend('sqlite')
      should create_class('pdns::nameserver::service')
    }
  end
  context 'sqlite backend' do
    let(:params) { { :backend => 'sqlite' }  }
    it {
      should create_class('pdns::nameserver::config').with_backend('sqlite').with_listen_address('127.0.0.1')
      should create_class('pdns::nameserver::install').with_backend('sqlite')
      should create_class('pdns::nameserver::service')
    }
  end
  context 'postgresql backend' do
    let(:params) { { :backend => 'postgresql' } }
    it {
      should create_class('pdns::nameserver::config').with_backend('postgresql').with_listen_address('127.0.0.1')
      should create_class('pdns::nameserver::install').with_backend('postgresql')
      should create_class('pdns::nameserver::service')
    }
  end
  #context 'invalid backend' do
  #  let(:params) { { :backend => 'anythingelse' } }
  #  it {
  #    should raise_error(Puppet::Error)
  #  }
  #end
end
