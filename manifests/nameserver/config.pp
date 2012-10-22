class pdns::nameserver::config (
  $backend        = undef,
  $listen_address = undef,
) {
  if $backend == undef {
    fail('pdns::nameserver::config backend parameter is required')
  }
  if $listen_address == undef {
    fail('pdns::nameserver::config listen_address parameter is required')
  }
  # defaults
  File {
    owner => 'pdns',
    group => 'pdns',
  }
  file { '/etc/pdns/pdns.conf':
    ensure  => present,
    mode    => '0400',
    content => template('pdns/nameserver/pdns.conf.erb'),
    notify  => Class['pdns::nameserver::service'],
  }
  case $backend {
    'postgresql': {
      file { '/etc/pdns/schema.sql':
        ensure => present,
        mode   => '0444',
        source => 'puppet:///modules/pdns/nameserver/postgresql-schema.sql',
      }
      file { '/etc/pdns/dbsetup.sh':
        ensure  => present,
        mode    => '0500',
        content => template('pdns/nameserver/postgresql-setup.sh.erb'),
      }
    }
    'sqlite': {
      file { '/etc/pdns/schema.sql':
        ensure => present,
        mode   => '0444',
        source => 'puppet:///modules/pdns/nameserver/sqlite-schema.sql',
      }
      file { '/var/pdns':
        ensure => directory,
      }
      file { '/etc/pdns/dbsetup.sh':
        ensure  => present,
        mode    => '0500',
        content => template('pdns/nameserver/sqlite-setup.sh.erb'),
      }
    }
    default: {
      fail("unknown backend - valid values are 'postgresql' or 'sqlite'")
    }
  }
  #iptables::allow{ 'dns_tcp': port => '53', protocol => 'tcp' }
  #iptables::allow{ 'dns_udp': port => '53', protocol => 'udp' }
}
