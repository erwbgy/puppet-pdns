# = Class: pdns::resolver
#
# Installs and configures a PowerDNS resolver - www.powerdns.com
#
# Makes it easy to point to a name server for an internal domain.
#
# Currently only supported on RedHat-based systems
#
# For more information see https://github.com/erwbgy/puppet-pdns/
class pdns::resolver(
  $listen_address = $::ipaddress,
  $dont_query     = undef,
  $forward_zones  = [],
  $forward_domain = undef,
  $reverse_domain = undef,
  $nameservers    = $::ipaddress,
  $use_hiera      = true
) {
  # Only run on RedHat derived systems.
  case $::osfamily {
    RedHat: { }
    default: {
      fail('This module only supports RedHat-based systems')
    }
  }
  if $use_hiera {
    $pdns     = hiera_hash('pdns')
    $resolver = $pdns['resolver']
    if ! $resolver {
      fail('pdns::resolver: no pdns resolver hash found in hiera config')
    }
    class { 'pdns::resolver::config':
      listen_address => $resolver['listen_address'] ? {
        undef   => $listen_address,
        default => $resolver['listen_address'],
      },
      dont_query => $resolver['dont_query'] ? {
        undef   => $dont_query,
        default => $resolver['dont_query'],
      },
      forward_zones => $resolver['forward_zones'] ? {
        undef   => $forward_zones,
        default => $resolver['forward_zones'],
      },
      forward_domain => $resolver['forward_domain'] ? {
        undef   => $forward_domain,
        default => $resolver['forward_domain'],
      },
      reverse_domain => $resolver['reverse_domain'] ? {
        undef   => $reverse_domain,
        default => $resolver['reverse_domain'],
      },
      nameservers => $resolver['nameservers'] ? {
        undef   => $nameservers,
        default => $resolver['nameservers'],
      },
    }
  }
  else {
    class { 'pdns::resolver::config':
      listen_address => $listen_address,
      dont_query     => $dont_query,
      forward_zones  => $forward_zones,
      forward_domain => $forward_domain,
      reverse_domain => $reverse_domain,
      nameservers    => $nameservers,
    }
  }
  require pdns::resolver::install
  require pdns::resolver::service
}
