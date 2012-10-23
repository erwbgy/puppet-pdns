class pdns::resolver::config (
  $listen_address = undef,
  $dont_query     = undef,
  $forward_zones  = undef
) {
  if $listen_address == undef {
    fail('pdns::resolver::config forward_zones is required')
  }
  if $dont_query == undef {
    case $::ipaddress {
      /^10\./:  { $_dont_query = '127.0.0.0/8, 192.168.0.0/16, 172.16.0.0/12, ::1/128' }
      /^172\./: { $_dont_query = '127.0.0.0/8, 10.0.0.0/8, 192.168.0.0/16, ::1/128' }
      /^192\./: { $_dont_query = '127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, ::1/128' }
      /^127\./: { $_dont_query = '10.0.0.0/8, 192.168.0.0/16, 172.16.0.0/12, ::1/128' }
      default:  { $_dont_query = undef }
    }
  }
  else {
    $_dont_query = $dont_query
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
