require 'spec_helper'

describe 'pdns::nameserver::config', :type => 'class' do
  let(:facts) { {
    :ipaddress => '10.0.0.1',
    :osfamily  => 'RedHat'
  } }
  context 'postgresql backend' do
    let(:params) { {
      :backend        => 'postgresql',
      :listen_address => '10.0.0.2',
    } }
    it {
      should contain_file('/etc/pdns/pdns.conf').with( {
        'ensure'  => 'present',
        'mode'    => '0400',
        'content' => "setuid=pdns\nsetgid=pdns\nlocal-address=10.0.0.2\nlaunch=gpgsql\ngpgsql-user=pdns\ngpgsql-dbname=powerdns\n",
        'notify'  => "Class[Pdns::Nameserver::Service]",
      } )
      should contain_file('/var/pdns/schema.sql').with( {
        'ensure'  => 'present',
        'mode'    => '0444',
        'source'  => 'puppet:///modules/pdns/nameserver/postgresql-schema.sql',
      } )
      should contain_file('/var/pdns/dbsetup.sh').with( {
        'ensure'  => 'present',
        'mode'    => '0500',
        'content' => "#!/bin/bash\nservice postgresql initdb\nservice postgresql start\nchkconfig postgresql on\nsudo -H -u postgres createdb powerdns\nsudo -H -u postgres psql powerdns < /etc/pdns/schema.sql\nSQL_FILE=$(mktemp '/tmp/pdnsdb-setup.XXXXXXXXXX')\n>$SQL_FILE\ncat <<EOT >>$SQL_FILE\nCREATE USER pdns PASSWORD O1HDV1MiJGkP066j;\nGRANT SELECT ON supermasters TO pdns;\nGRANT ALL ON domains TO pdns;\nGRANT ALL ON domains_id_seq TO pdns;\nGRANT ALL ON records TO pdns;\nGRANT ALL ON records_id_seq TO pdns;\nEOT\nsudo -H -u postgres psql powerdns < $SQL_FILE\nrm -f $SQL_FILE\n",
      } )
    }
  end
  context 'sqlite backend' do
    let(:params) { {
      :backend        => 'sqlite',
      :listen_address => '10.0.0.2',
    } }
    it {
      should contain_file('/etc/pdns/pdns.conf').with( {
        'ensure'  => 'present',
        'mode'    => '0400',
        'content' => "setuid=pdns\nsetgid=pdns\nlocal-address=10.0.0.2\nlaunch=gsqlite3\ngsqlite3-database=/var/pdns/powerdns.sqlite\n",
        'notify'  => "Class[Pdns::Nameserver::Service]",
      } )
      should contain_file('/var/pdns/schema.sql').with( {
        'ensure'  => 'present',
        'mode'    => '0444',
        'source'  => 'puppet:///modules/pdns/nameserver/sqlite-schema.sql',
      } )
      should contain_file('/var/pdns/dbsetup.sh').with( {
        'ensure'  => 'present',
        'mode'    => '0500',
        'content' => "#!/bin/bash\nsqlite3 /var/pdns/powerdns.sqlite < /etc/pdns/schema.sql\nSQL_FILE=$(mktemp '/tmp/pdnsdb-setup.XXXXXXXXXX')\n>$SQL_FILE\nrm -f $SQL_FILE\n",
      } )
    }
  end
  context 'postgresql backend with .local domain and no reverse' do
    let(:params) { {
      :backend        => 'postgresql',
      :listen_address => '10.0.0.2',
      :forward_domain => 'local',
    } }
    it {
      should contain_file('/etc/pdns/pdns.conf').with( {
        'ensure'  => 'present',
        'mode'    => '0400',
        'content' => "setuid=pdns\nsetgid=pdns\nlocal-address=10.0.0.2\nlaunch=gpgsql\ngpgsql-user=pdns\ngpgsql-dbname=powerdns\n",
        'notify'  => "Class[Pdns::Nameserver::Service]",
      } )
      should contain_file('/var/pdns/schema.sql').with( {
        'ensure'  => 'present',
        'mode'    => '0444',
        'source'  => 'puppet:///modules/pdns/nameserver/postgresql-schema.sql',
      } )
      should contain_file('/var/pdns/dbsetup.sh').with( {
        'ensure'  => 'present',
        'mode'    => '0500',
        'content' => "#!/bin/bash\nservice postgresql initdb\nservice postgresql start\nchkconfig postgresql on\nsudo -H -u postgres createdb powerdns\nsudo -H -u postgres psql powerdns < /etc/pdns/schema.sql\nSQL_FILE=$(mktemp '/tmp/pdnsdb-setup.XXXXXXXXXX')\n>$SQL_FILE\ncat <<EOT >>$SQL_FILE\nCREATE USER pdns PASSWORD O1HDV1MiJGkP066j;\nGRANT SELECT ON supermasters TO pdns;\nGRANT ALL ON domains TO pdns;\nGRANT ALL ON domains_id_seq TO pdns;\nGRANT ALL ON records TO pdns;\nGRANT ALL ON records_id_seq TO pdns;\nEOT\ncat <<EOT >>$SQL_FILE\nINSERT INTO \"domains\" (name, type) VALUES('local','MASTER');\nINSERT INTO \"records\" (domain_id, name, type, content, ttl, prio) VALUES(1,'local','NS','ns1.local',86400,NULL);\nINSERT INTO \"records\" (domain_id, name, type, content, ttl, prio) VALUES(1,'local','SOA','ns1.local',86400,NULL);\nINSERT INTO \"records\" (domain_id, name, type, content, ttl, prio) VALUES(1,'ns1.local','A','10.0.0.2',3600,NULL);\nINSERT INTO \"domains\" (name, type) VALUES('10.in-addr.arpa','MASTER');\nINSERT INTO \"records\" (reverse_id, name, type, content, ttl, prio) VALUES(1,'10.in-addr.arpa','NS','10.in-addr.arpa',86400,NULL);\nINSERT INTO \"records\" (reverse_id, name, type, content, ttl, prio) VALUES(1,'10.in-addr.arpa','SOA','10.in-addr.arpa',86400,NULL);\nINSERT INTO \"records\" (reverse_id, name, type, content, ttl, prio) VALUES(1,'10.in-addr.arpa','A','10.0.0.2',3600,NULL);\nEOT\nsudo -H -u postgres psql powerdns < $SQL_FILE\nrm -f $SQL_FILE\n",
      } )
    }
  end
  context 'sqlite backend with .local domain and no reverse' do
    let(:params) { {
      :backend        => 'sqlite',
      :listen_address => '10.0.0.2',
      :forward_domain => 'local',
    } }
    it {
      should contain_file('/etc/pdns/pdns.conf').with( {
        'ensure'  => 'present',
        'mode'    => '0400',
        'content' => "setuid=pdns\nsetgid=pdns\nlocal-address=10.0.0.2\nlaunch=gsqlite3\ngsqlite3-database=/var/pdns/powerdns.sqlite\n",
        'notify'  => "Class[Pdns::Nameserver::Service]",
      } )
      should contain_file('/var/pdns/schema.sql').with( {
        'ensure'  => 'present',
        'mode'    => '0444',
        'source'  => 'puppet:///modules/pdns/nameserver/sqlite-schema.sql',
      } )
      should contain_file('/var/pdns/dbsetup.sh').with( {
        'ensure'  => 'present',
        'mode'    => '0500',
        'content' => "#!/bin/bash\nsqlite3 /var/pdns/powerdns.sqlite < /etc/pdns/schema.sql\nSQL_FILE=$(mktemp '/tmp/pdnsdb-setup.XXXXXXXXXX')\n>$SQL_FILE\ncat <<EOT >>$SQL_FILE\nINSERT INTO \"domains\" (name, type) VALUES('local','MASTER');\nINSERT INTO \"records\" (domain_id, name, type, content, ttl, prio) VALUES(1,'local','NS','ns1.local',86400,NULL);\nINSERT INTO \"records\" (domain_id, name, type, content, ttl, prio) VALUES(1,'local','SOA','ns1.local',86400,NULL);\nINSERT INTO \"records\" (domain_id, name, type, content, ttl, prio) VALUES(1,'ns1.local','A','10.0.0.2',3600,NULL);\nINSERT INTO \"domains\" (name, type) VALUES('10.in-addr.arpa','MASTER');\nINSERT INTO \"records\" (reverse_id, name, type, content, ttl, prio) VALUES(1,'10.in-addr.arpa','NS','10.in-addr.arpa',86400,NULL);\nINSERT INTO \"records\" (reverse_id, name, type, content, ttl, prio) VALUES(1,'10.in-addr.arpa','SOA','10.in-addr.arpa',86400,NULL);\nINSERT INTO \"records\" (reverse_id, name, type, content, ttl, prio) VALUES(1,'10.in-addr.arpa','A','10.0.0.2',3600,NULL);\nEOT\nrm -f $SQL_FILE\n",
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
