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
#      type        => 'nameserver',
#      backend     => 'sqlite'
#    }
#
#    class { 'pdns::nameserver':
#      type        => 'nameserver',
#      backend     => 'postgresql'
#      db_password => 'sngy3ouunVKbg4zqYmyFqw'
#    }
#
class pdns::nameserver(
  $listen_address = $::ipaddress,
  $backend        = 'postgresql',
  $db_password    = 'vrJRcqfj3Ar1uDuY',
) {
  # Only run on RedHat derived systems.
  case $::osfamily {
    RedHat: { }
    default: {
      fail('This module only supports RedHat-based systems')
    }
  }
  require pdns::nameserver::config, pdns::nameserver::install, pdns::nameserver::service
}
