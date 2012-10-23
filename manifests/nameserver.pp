# = Class: pdns::nameserver
#
# Installs and configures a PowerDNS nameserver - www.powerdns.com
#
# Currently supported backends: sqlite, postgresql
#
# Only supported on RedHat-based systems
#
# For more information see https://github.com/erwbgy/puppet-pdns/
class pdns::nameserver(
  $listen_address = $::ipaddress,
  $backend        = 'sqlite',
  $use_hiera      = false,
  $forward_domain = undef,
  $reverse_domain = undef
) {
  # Only run on RedHat derived systems.
  case $::osfamily {
    RedHat: { }
    default: {
      fail('This module only supports RedHat-based systems')
    }
  }
  if $use_hiera {
    $pdns_nameserver = hiera['pdns_nameserver']
    class { 'pdns::nameserver::config':
      backend        => $pdns_nameserver['backend'],
      listen_address => $pdns_nameserver['listen_address'],
      forward_domain => $pdns_nameserver['forward_domain'],
      reverse_domain => $pdns_nameserver['reverse_domain'],
    }
    class { 'pdns::nameserver::install':
      backend        => $pdns_nameserver['backend'],
    }
  }
  else {
    class { 'pdns::nameserver::config':
      backend        => $backend,
      listen_address => $listen_address,
      forward_domain => $forward_domain,
      reverse_domain => $reverse_domain,
    }
    class { 'pdns::nameserver::install':
      backend        => $backend,
    }
  }
  require pdns::nameserver::service
}
