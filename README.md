# puppet-pdns

Manage PowerDNS configuration using Puppet

Run either a PowerDNS name server or a PowerDNS resolver

## pdns::nameserver

Run a PowerDNS name server to answer hostname/IP queries from DNS resolvers for
a specific set of domains managed by the name server.

### Parameters

*backend*: database backend to use - one of: _sqlite_ or _postgresql_. Default: _sqlite_.

*listen_address*: IP to listen on. Default: _$::ipaddress_

### Examples

PowerDNS name server with Postgresql backend:

    class { 'pdns::nameserver':
      backend => 'postgresql'
    }

PowerDNS name server with SQLite backend

    class { 'pdns::nameserver':
      backend => 'sqlite'
    }

## pdns::resolver

Run a PowerDNS resolver that contacts the appropriate DNS name servers on
behalf of clients to covert a hostname into an IP or an IP into a hostname.
(The IP address of a DNS resolver is what is specified in /etc/resolv.conf on
Linux/Unix hosts.)

### Parameters

*listen_address*: IP to listen on. Default: _$::ipaddress_

*dont_query*: IP ranges to exclude from lookups. Default: '10.0.0.0/8, 192.168.0.0/16, 172.16.0.0/12, ::1/128'

*forward_zones*: specify name server IPs for specific domains

### Examples

PowerDNS resolver:

    class { 'pdns::resolver':
      listen_address => $::ipaddress_lo,
      dont_query     => '192.168.0.0/16, 172.16.0.0/12, ::1/128',
      forward_zones  => [ 'local=10.5.11.16', '5.10.in-addr.arpa=10.5.11.16' ]
    }

## Support

License: Apache License, Version 2.0

GitHub URL: https://github.com/erwbgy/puppet-pdns
