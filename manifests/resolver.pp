class pdns::resolver(
  $listen_address = $::ipaddress,
  $dont_query     = undef,
  $forward_zones  = undef,
  $use_hiera      = false,
  $forward_domain = undef,
  $reverse_domain = undef,
  $nameserver     = undef
) {
  # Only run on RedHat derived systems.
  case $::osfamily {
    RedHat: { }
    default: {
      fail('This module only supports RedHat-based systems')
    }
  }
  if $use_hiera {
    $pdns_resolver = hiera('pdns_resolver')
    class { 'pdns::resolver::config':
      listen_address => $pdns_resolver['listen_address'],
      dont_query     => $pdns_resolver['dont_query'],
      forward_zones  => $pdns_resolver['forward_zones'],
      forward_domain => $pdns_resolver['forward_domain'],
      reverse_domain => $pdns_resolver['reverse_domain'],
      nameserver     => $pdns_resolver['nameserver'],
    } 
  }
  else {
    class { 'pdns::resolver::config':
      listen_address => $listen_address,
      dont_query     => $dont_query,
      forward_zones  => $forward_zones,
      forward_domain => $forward_domain,
      reverse_domain => $reverse_domain,
      nameserver     => $nameserver,
    } 
  }
  require pdns::resolver::install
  require pdns::resolver::service
}
