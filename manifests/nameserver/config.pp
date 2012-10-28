class pdns::nameserver::config (
  $backend        = 'sqlite',
  $listen_address = $::ipaddress,
  $forward_domain = undef,
  $reverse_domain = undef
) {
  if $backend == undef {
    fail('pdns::nameserver::config backend parameter is required')
  }
  if $listen_address == undef {
    fail('pdns::nameserver::config listen_address parameter is required')
  }

  # Set the reverse domain based on the current IP address
  if $reverse_domain {
    $reverse = $reverse_domain
  }
  if $forward_domain and !$reverse_domain {
    case $listen_address {
      /^127\./: { $reverse = '127.in-addr.arpa' }
      /^10\./:  { $reverse = '10.in-addr.arpa' }
      /^172\./: { $reverse = '16.172.in-addr.arpa' }
      /^192\./: { $reverse = '168.192.in-addr.arpa' }
      default: {
        err("listen_address is ${listen_address}")
        err("::ipaddress is ${::ipaddress}")
        fail('pdns::nameserver::config forward_domain is set but reverse_domain is not and must be')
      }
    }
    notify { "setting reverse_domain to ${reverse} based on IP address ${::ipaddress}": }
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
    require => Package['pdns'],
    notify  => Class['pdns::nameserver::service'],
  }
  file { '/var/pdns':
    ensure  => directory,
    mode    => '0755',
    require => Package['pdns'],
  }
  case $backend {
    'postgresql': {
      file { '/var/pdns/schema.sql':
        ensure  => present,
        mode    => '0444',
        source  => 'puppet:///modules/pdns/nameserver/postgresql-schema.sql',
        require => File['/var/pdns'],
      }
    }
    'sqlite': {
      file { '/var/pdns/schema.sql':
        ensure  => present,
        mode    => '0444',
        source  => 'puppet:///modules/pdns/nameserver/sqlite-schema.sql',
        require => File['/var/pdns'],
      }
    }
    default: {
      fail("unknown backend - valid values are 'postgresql' or 'sqlite'")
    }
  }
  file { '/var/pdns/dbsetup.sh':
    ensure  => present,
    mode    => '0555',
    content => template('pdns/nameserver/dbsetup.sh.erb'),
    notify  => Exec['pdns-dbsetup'],
    require => File['/var/pdns'],
  }
  file { '/var/pdns/add_host_entries':
    ensure  => present,
    mode    => '0555',
    content => template('pdns/nameserver/add_host_entries.erb'),
    require => File['/var/pdns'],
  }
  file { '/etc/pdns/add_host':
    ensure  => present,
    mode    => '0555',
    content => template('pdns/nameserver/add_host.erb'),
    require => Package['pdns'],
  }
  file { '/var/pdns/add_cname_entries':
    ensure  => present,
    mode    => '0555',
    content => template('pdns/nameserver/add_cname_entries.erb'),
    require => Package['pdns'],
  }
  file { '/etc/pdns/add_cname':
    ensure  => present,
    mode    => '0555',
    content => template('pdns/nameserver/add_cname.erb'),
    require => Package['pdns'],
  }
  file { '/etc/pdns/show':
    ensure  => present,
    mode    => '0555',
    content => template('pdns/nameserver/show.erb'),
    require => Package['pdns'],
  }
  #iptables::allow{ 'dns_tcp': port => '53', protocol => 'tcp' }
  #iptables::allow{ 'dns_udp': port => '53', protocol => 'udp' }
}
