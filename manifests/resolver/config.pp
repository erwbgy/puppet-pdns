class pdns::resolver::config (
  $listen_address = undef,
  $dont_query     = undef,
  $forward_zones  = []
) {
  if $listen_address == undef {
    fail('pdns::resolver::config forward_zones is required')
  }
  if $dont_query == undef {
    fail('pdns::resolver::config forward_zones is required')
  }
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
}
