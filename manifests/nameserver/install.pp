class pdns::nameserver::install (
  $backend = undef
) {
  if $backend == undef {
    fail('pdns::nameserver::install backend parameter is required')
  }

  if ! defined(Package['pdns']) {
    package { 'pdns': ensure => installed }
  }
  if ! defined(Package['coreutils']) {
    package { 'coreutils': ensure => installed }
  }
  if ! defined(Package['bash']) {
    package { 'bash': ensure => installed }
  }

  case $backend {
    'postgresql': {
      if ! defined(Package['postgresql']) {
        package { 'postgresql': ensure => installed }
      }
      if ! defined(Package['postgresql-server']) {
        package { 'postgresql-server': ensure => installed }
      }
      if ! defined(Package['pdns-backend-postgresql']) {
        package { 'pdns-backend-postgresql': ensure => installed }
      }
      if ! defined(Package['perl-DBI']) {
        package { 'perl-DBI': ensure => installed }
      }
      if ! defined(Package['perl-DBD-Pg']) {
        package { 'perl-DBD-Pg': ensure => installed }
      }
      if ! defined(Package['sudo']) {
        package { 'sudo': ensure => installed }
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
      if ! defined(Package['sqlite']) {
        package { 'sqlite': ensure => installed }
      }
      if ! defined(Package['pdns-backend-sqlite']) {
        package { 'pdns-backend-sqlite': ensure => installed }
      }
      if ! defined(Package['perl-DBI']) {
        package { 'perl-DBI': ensure => installed }
      }
      if ! defined(Package['perl-DBD-SQLite']) {
        package { 'perl-DBD-SQLite': ensure => installed }
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
