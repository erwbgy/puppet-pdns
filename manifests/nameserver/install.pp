class pdns::nameserver::install {
  package { [
    'pdns',
    'coreutils',
    'bash'
  ]:
    ensure => installed,
  }
  if $pdns::nameserver::backend == 'postgresql' {
    package { [
      'postgresql',
      'postgresql-server',
      'pdns-backend-postgresql',
      'perl-DBI',
      'perl-DBD-Pg'
    ]:
      ensure => installed,
    }
    exec { 'pdns-dbsetup':
      command     => '/etc/pdns/dbsetup.sh',
      require     => Class['pdns::nameserver::config'],
      subscribe   =>
        Package[
          'postgresql',
          'postgresql-server',
          'pdns-backend-postgresql'
        ],
      refreshonly => true,
    }
  }
  elsif $pdns::nameserver::backend == 'sqlite' {
    package { [
      'sqlite',
      'pdns-backend-sqlite',
      'perl-DBI',
      'perl-DBD-SQLite'
    ]:
      ensure => installed,
    }
    exec { 'pdns-dbsetup':
      command     => '/etc/pdns/dbsetup.sh',
      require     => Class['pdns::nameserver::config'],
      subscribe   => Package['sqlite', 'pdns-backend-sqlite'],
      creates     => '/var/pdns/powerdns.sqlite',
    }
  }
}
