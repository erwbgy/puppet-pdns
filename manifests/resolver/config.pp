class pdns::resolver::config {
  # defaults
  File {
    owner => 'pdns-recursor',
    group => 'pdns-recursor',
  }
  file { '/etc/pdns-recursor/recursor.conf':
    ensure  => present,
    mode    => '0444',
    content => template('pdns/resolver/recursor.conf.erb'),
    notify  => Class['pdns::resolver::service'],
  }
  file { '/etc/pdns-recursor/forward_zones':
    ensure  => present,
    mode    => '0444',
    content => template('pdns/resolver/forward_zones.erb'),
    notify  => Class['pdns::resolver::service'],
  }
  realize( User['pdns-recursor'] )
}
