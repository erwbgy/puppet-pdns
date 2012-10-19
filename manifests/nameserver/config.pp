class pdns::nameserver::config {
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
  if $pdns::nameserver::backend == 'postgresql' {
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
  elsif $pdns::nameserver::backend == 'sqlite' {
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
  else {
    fail('Only the postgresql and sqlite backends are currently supported')
  }
  realize( User['pdns'], )
  iptables::allow{ 'dns_tcp': port => '53', protocol => 'tcp' }
  iptables::allow{ 'dns_udp': port => '53', protocol => 'udp' }
}
