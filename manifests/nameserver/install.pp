class pdns::nameserver::install (
  $backend = undef
) {
  if $backend == undef {
    fail('pdns::nameserver::install backend parameter is required')
  }
  package { [
    'pdns',
    'coreutils',
    'bash'
  ]:
    ensure => installed,
  }
  case $backend {
    'postgresql': {
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
        command     => '/var/pdns/dbsetup.sh',
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
    'sqlite': {
      package { [
        'sqlite',
        'pdns-backend-sqlite',
        'perl-DBI',
        'perl-DBD-SQLite'
      ]:
        ensure => installed,
      }
      exec { 'pdns-dbsetup':
        command     => '/var/pdns/dbsetup.sh',
        require     => Class['pdns::nameserver::config'],
        subscribe   => Package['sqlite', 'pdns-backend-sqlite'],
        creates     => '/var/pdns/powerdns.sqlite',
        # TODO: check that exit code is 0
      }
      file { '/var/pdns/powerdns.sqlite':
        ensure  => present,
        owner   => 'pdns',
        group   => 'pdns',
        mode    => '0600',
        require => Exec['pdns-dbsetup']
      }
    }
    default: {
      fail("unknown backend - valid values are 'postgresql' or 'sqlite'")
    }
  }
}
