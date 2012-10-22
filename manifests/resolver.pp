class pdns::resolver(
  $listen_address = $::ipaddress,
  $dont_query     = '192.168.0.0/16, 172.16.0.0/12, ::1/128',
  $forward_zones  = undef,
  $use_hiera      = false,
) {
  # TODO: Check $::ipaddress to see what to leave out of dont_query
  # Only run on RedHat derived systems.
  case $::osfamily {
    RedHat: { }
    default: {
      fail('This module only supports RedHat-based systems')
    }
  }
  if $use_hiera {
    class { 'pdns::resolver::config':
      listen_address => hiera('ntp_servers', $listen_address),
      dont_query     => hiera('ntp_servers', $dont_query),
      forward_zones  => hiera('ntp_servers', $forward_zones),
    } 
  }
  else {
    class { 'pdns::resolver::config':
      listen_address => $listen_address,
      dont_query     => $dont_query,
      forward_zones  => $forward_zones,
    } 
  }
  require pdns::resolver::install
  require pdns::resolver::service
}
