require 'spec_helper'

describe 'pdns::nameserver::config', :type => 'class' do
  context 'postgresql backend' do
    let(:params) { {
      :backend        => 'postgresql',
      :listen_address => '127.0.0.1',
    } }
    it {
      should contain_file('/etc/pdns/pdns.conf').with( {
        'ensure'  => 'present',
        'mode'    => '0400',
        'content' => "setuid=pdns\nsetgid=pdns\nlocal-address=127.0.0.1\nlaunch=gpgsql\ngpgsql-user=pdns\ngpgsql-dbname=powerdns\n",
        'notify'  => "Class[Pdns::Nameserver::Service]",
      } )
      should contain_file('/etc/pdns/schema.sql').with( {
        'ensure'  => 'present',
        'mode'    => '0444',
        'source'  => 'puppet:///modules/pdns/nameserver/postgresql-schema.sql',
      } )
      should contain_file('/etc/pdns/dbsetup.sh').with( {
        'ensure'  => 'present',
        'mode'    => '0500',
        'content' => "#!/bin/bash\nservice postgresql initdb\nservice postgresql start\nchkconfig postgresql on\nsudo -H -u postgres createdb powerdns\nsudo -H -u postgres psql powerdns < /etc/pdns/schema.sql\nSQL_FILE=$(mktemp '/tmp/postgres-setup.XXXXXXXXXX')\necho \"CREATE USER pdns PASSWORD 'undefined';\" > $SQL_FILE\necho \"GRANT SELECT ON supermasters TO pdns;\" >> $SQL_FILE\necho \"GRANT ALL ON domains TO pdns;\" >> $SQL_FILE\necho \"GRANT ALL ON domains_id_seq TO pdns;\" >> $SQL_FILE\necho \"GRANT ALL ON records TO pdns;\" >> $SQL_FILE\necho \"GRANT ALL ON records_id_seq TO pdns;\" >> $SQL_FILE\nsudo -H -u postgres psql powerdns < $SQL_FILE\nrm -f $SQL_FILE\n",
      } )
    }
  end
  context 'sqlite backend' do
    let(:params) { {
      :backend        => 'sqlite',
      :listen_address => '127.0.0.1',
    } }
    it {
      should contain_file('/etc/pdns/pdns.conf').with( {
        'ensure'  => 'present',
        'mode'    => '0400',
        'content' => "setuid=pdns\nsetgid=pdns\nlocal-address=127.0.0.1\nlaunch=gsqlite3\ngsqlite3-database=/var/pdns/powerdns.sqlite\n",
        'notify'  => "Class[Pdns::Nameserver::Service]",
      } )
      should contain_file('/etc/pdns/schema.sql').with( {
        'ensure'  => 'present',
        'mode'    => '0444',
        'source'  => 'puppet:///modules/pdns/nameserver/sqlite-schema.sql',
      } )
      should contain_file('/etc/pdns/dbsetup.sh').with( {
        'ensure'  => 'present',
        'mode'    => '0500',
        'content' => "#!/bin/bash\nsqlite3 /var/pdns/powerdns.sqlite < /etc/pdns/schema.sql\n",
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
