# = Class: pdns::nameserver
#
# Installs and configures a PowerDNS nameserver - www.powerdns.com
#
# Currently supported backends: sqlite, postgresql
#
# Only supported on RedHat-based systems
#
# == Parameters:
#
# $listen_address:: The IP address that the nameserver listens on. Defaults to
#                   the primary IP address of the host.
# $backend::        The database backend store for DNS data. Possible values
#                   are 'postgresql' or 'sqlite'. Defaults to 'sqlite'.
# $db_password::    The password to be used for the database user.  Not 
#                   applicable for sqlite.  A default value is set but should
#                   not normally be used.
#
# == Examples:
#
#    class { 'pdns::nameserver':
#      backend     => 'sqlite'
#    }
#
#    class { 'pdns::nameserver':
#      backend     => 'postgresql'
#    }
#
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
    class { 'pdns::nameserver::config':
      backend        => hiera('pdns_nameserver_backend', $backend),
      listen_address => hiera('pdns_nameserver_listen_address', $listen_address),
      forward_domain => hiera('pdns_nameserver_forward_domain', $forward_domain),
      reverse_domain => hiera('pdns_nameserver_reverse_domain', $reverse_domain),
    }
    class { 'pdns::nameserver::install':
      backend => hiera('pdns_nameserver_backend', $backend),
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
