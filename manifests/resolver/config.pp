class pdns::resolver::config (
  $listen_address = $::ipaddress,
  $dont_query     = undef,
  $forward_zones  = [],
  $forward_domain = undef,
  $reverse_domain = undef,
  $nameserver     = $::ipaddress
) {
  if $forward_domain {
    # By default the pdns recursor will not send queries to local addresses
    # but if we are running a local domain then we need to change this to
    # enable queries to our name server
    if $dont_query == undef {
      case $nameserver {
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

    # Set the reverse domain based on the nameserver IP address
    if $reverse_domain {
      $_reverse_domain = $reverse_domain
    }
    else {
      case $nameserver {
        /^127\./: { $_reverse_domain = '127.in-addr.arpa' }
        /^10\./:  { $_reverse_domain = '10.in-addr.arpa' }
        /^172\./: { $_reverse_domain = '16.172.in-addr.arpa' }
        /^192\./: { $_reverse_domain = '168.192.in-addr.arpa' }
        default: {
          fail('pdns::resolver::config forward_domain is set but reverse_domain is not and must be')
        }
      }
      notify { "setting reverse_domain to ${_reverse_domain} based on nameserver IP address ${nameserver}": }
    }
    $_forward_zones = [
      "${forward_domain}=${nameserver}",
      "${_reverse_domain}=${nameserver}"
    ]
  }
  else {
    $_dont_query    = $dont_query
    $_forward_zones = $forward_zones
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
    require => Package['pdns-recursor'],
    notify  => Class['pdns::resolver::service'],
  }
  file { '/etc/pdns-recursor/forward_zones':
    ensure  => present,
    mode    => '0444',
    content => template('pdns/resolver/forward_zones.erb'),
    require => Package['pdns-recursor'],
    notify  => Class['pdns::resolver::service'],
  }
}
