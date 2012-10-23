require 'spec_helper'

describe 'pdns::resolver::config', :type => 'class' do
  let(:facts) { {
    :ipaddress => '10.0.0.1',
    :osfamily  => 'RedHat'
  } }
  context 'no forward zones' do
    let(:params) { {
      :listen_address => '127.0.0.1',
      :dont_query     => '192.168.0.0/16, 172.16.0.0/12, ::1/128',
      :forward_zones  => nil,
    } }
    it {
      should contain_file('/etc/pdns-recursor/recursor.conf').with( {
        'ensure'  => 'present',
        'mode'    => '0444',
        'content' => "setuid=pdns-recursor\nsetgid=pdns-recursor\nlocal-address=127.0.0.1\ndont-query=192.168.0.0/16, 172.16.0.0/12, ::1/128\nforward-zones-file=/etc/pdns-recursor/forward_zones\n",
        'notify'  => "Class[Pdns::Resolver::Service]",
      } )
      should contain_file('/etc/pdns-recursor/forward_zones').with( {
        'ensure'  => 'present',
        'mode'    => '0444',
        'content' => "nil\n",
        'notify'  => "Class[Pdns::Resolver::Service]",
      } )
    }
  end
  context 'with forward zones' do
    let(:params) { {
      :listen_address => '127.0.0.1',
      :dont_query     => '192.168.0.0/16, 172.16.0.0/12, ::1/128',
      :forward_zones  => [ 'local=10.5.11.16', '5.10.in-addr.arpa=10.5.11.16' ],
    } }
    it {
      should contain_file('/etc/pdns-recursor/recursor.conf').with( {
        'ensure'  => 'present',
        'mode'    => '0444',
        'content' => "setuid=pdns-recursor\nsetgid=pdns-recursor\nlocal-address=127.0.0.1\ndont-query=192.168.0.0/16, 172.16.0.0/12, ::1/128\nforward-zones-file=/etc/pdns-recursor/forward_zones\n",
        'notify'  => "Class[Pdns::Resolver::Service]",
      } )
      should contain_file('/etc/pdns-recursor/forward_zones').with( {
        'ensure'  => 'present',
        'mode'    => '0444',
        'content' => "local=10.5.11.16\n5.10.in-addr.arpa=10.5.11.16\n",
        'notify'  => "Class[Pdns::Resolver::Service]",
      } )
    }
  end
  context 'with domain .local on 127.x address' do
    let(:params) { {
      :listen_address => '127.0.0.1',
      :forward_domain => 'local',
      :nameserver     => '127.0.0.1',
    } }
    it {
      should contain_file('/etc/pdns-recursor/recursor.conf').with( {
        'ensure'  => 'present',
        'mode'    => '0444',
        'content' => "setuid=pdns-recursor\nsetgid=pdns-recursor\nlocal-address=127.0.0.1\ndont-query=10.0.0.0/8, 192.168.0.0/16, 172.16.0.0/12, ::1/128\nforward-zones-file=/etc/pdns-recursor/forward_zones\n",
        'notify'  => "Class[Pdns::Resolver::Service]",
      } )
      should contain_file('/etc/pdns-recursor/forward_zones').with( {
        'ensure'  => 'present',
        'mode'    => '0444',
        'content' => "local=127.0.0.1\n127.in-addr.arpa=127.0.0.1\n",
        'notify'  => "Class[Pdns::Resolver::Service]",
      } )
    }
  end
  context 'with domain .local on 192.168.x address' do
    let(:params) { {
      :listen_address => '127.0.0.1',
      :forward_domain => 'local',
      :nameserver     => '192.168.0.1',
    } }
    it {
      should contain_file('/etc/pdns-recursor/recursor.conf').with( {
        'ensure'  => 'present',
        'mode'    => '0444',
        'content' => "setuid=pdns-recursor\nsetgid=pdns-recursor\nlocal-address=127.0.0.1\ndont-query=127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, ::1/128\nforward-zones-file=/etc/pdns-recursor/forward_zones\n",
        'notify'  => "Class[Pdns::Resolver::Service]",
      } )
      should contain_file('/etc/pdns-recursor/forward_zones').with( {
        'ensure'  => 'present',
        'mode'    => '0444',
        'content' => "local=192.168.0.1\n168.192.in-addr.arpa=192.168.0.1\n",
        'notify'  => "Class[Pdns::Resolver::Service]",
      } )
    }
  end
  context 'with domain .local specifying reverse zone' do
    let(:params) { {
      :listen_address => '127.0.0.1',
      :forward_domain => 'local',
      :reverse_domain => '0.16.172.in-addr.arpa',
      :nameserver     => '172.16.0.1',
    } }
    it {
      should contain_file('/etc/pdns-recursor/recursor.conf').with( {
        'ensure'  => 'present',
        'mode'    => '0444',
        'content' => "setuid=pdns-recursor\nsetgid=pdns-recursor\nlocal-address=127.0.0.1\ndont-query=127.0.0.0/8, 10.0.0.0/8, 192.168.0.0/16, ::1/128\nforward-zones-file=/etc/pdns-recursor/forward_zones\n",
        'notify'  => "Class[Pdns::Resolver::Service]",
      } )
      should contain_file('/etc/pdns-recursor/forward_zones').with( {
        'ensure'  => 'present',
        'mode'    => '0444',
        'content' => "local=172.16.0.1\n0.16.172.in-addr.arpa=172.16.0.1\n",
        'notify'  => "Class[Pdns::Resolver::Service]",
      } )
    }
  end
  #context 'invalid backend' do
  #  let(:params) { { :backend => 'anythingelse' } }
  #  it {
  #    should raise_error(Puppet::Error)
  #  }
  #end
end
