class pdns::resolver(
  $listen_address = $::ipaddress,
  $dont_query     = '192.168.0.0/16, 172.16.0.0/12, ::1/128',
  $forward_zones  = undef
) {
  # TODO: Check $::ipaddress to see what to leave out of dont_query
  # TODO: Add use_extlookup and use_hiera to look up values in extlookup and hiera
  # Only run on RedHat derived systems.
  case $::osfamily {
    RedHat: { }
    default: {
      fail('This module only supports RedHat-based systems')
    }
  }
  require pdns::resolver::config
  require pdns::resolver::install
  require pdns::resolver::service
}
