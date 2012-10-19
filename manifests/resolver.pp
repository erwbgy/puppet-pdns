class pdns::resolver(
  $listen_address = $::ipaddress,
  $dont_query     = '192.168.0.0/16, 172.16.0.0/12, ::1/128',
  $forward_zones  = undef
) {
  # Only run on RedHat derived systems.
  case $::osfamily {
    RedHat: { }
    default: {
      fail('This module only supports RedHat-based systems')
    }
  }
  require pdns::resolver::config, pdns::resolver::install, pdns::resolver::service
}
