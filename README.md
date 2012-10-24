# puppet-pdns

Manage PowerDNS configuration using Puppet

Run either a PowerDNS name server or a PowerDNS resolver

## pdns::nameserver

Run a PowerDNS name server to authoritatively answer hostname/IP queries from DNS
resolvers for a specific set of domains managed by the name server.

### Parameters

*use_hiera*: look up configuration under 'pdns_nameserver' hash in hiera

*backend*: database backend to use - one of: _sqlite_ or _postgresql_. Default: _sqlite_.

*listen_address*: IP to listen on. Default: _$::ipaddress_

*forward_domain*: Internal domain name (eg. .local). Default: undef

*reverse_domain*: Reverse .in-addr.arpa domain name for the forward domain (eg.
10.in-addr.arpa).  If forward domain is specified and this is not set then it
is derived from the listen_address.  Default: undef

#### Hiera configuration

Parameters can be specified in hiera configuration files under the
'pdns_nameserver' hash:

    pdns_nameserver:
      backend: ...
      listen_address: ...
      forward_domain: ...
      reverse_domain: ...

### Examples

Assuming that the primary IP address is a 10.17.0.1:

1) PowerDNS name server with SQLite backend

    class { 'pdns::nameserver': }

or:

    class { 'pdns::nameserver':
      backend => 'sqlite'
    }

which is the same as:

    class { 'pdns::nameserver':
      backend        => 'sqlite',
      listen_address => '10.17.0.1',
    }

2) PowerDNS name server with Postgresql backend:

    class { 'pdns::nameserver':
      backend => 'postgresql'
    }

which is the same as:

    class { 'pdns::nameserver':
      backend        => 'postgresql',
      listen_address => '10.17.0.1',
    }

3) PowerDNS name server configured with an internal .local domain:

    class { 'pdns::nameserver':
      forward_domain => 'local'
    }

which is the same as:

    class { 'pdns::nameserver':
      backend        => 'sqlite',
      listen_address => '10.17.0.1',
      forward_domain => 'local',
      reverse_domain => '10.in-addr.arpa',
    }

### Scripts

Use the `add_host` script to add an A record for a hostname - for example add
an A record for the _prod1_ host with IP _10.0.0.3_:

    # /etc/pdns/add_host prod1 10.0.0.3
    Adding A record for host x120.local with IP 10.0.0.3: ok
    Adding PTR record for IP 10.0.0.3 with host prod1.local: ok
    Restarting name server: ok
    $ host prod1
    prod1.local has address 10.0.0.3

Use the `add_cname` script to add an CNAME record (alias) for a hostname - for
example to add an alias for the _prod1_ host called _puppet_:

    # /etc/pdns/add_cname puppet prod1
    Adding CNAME record: alias puppet.local, host prod1.local: ok
    Restarting name server: ok
    $ host puppet
    puppet.local is an alias for prod1.local.
    prod1.local has address 10.0.0.1

Use the `show` script to see the entries in the database - for example:

    # /etc/pdns/show 
               name            | type  |   content    
    ---------------------------+-------+--------------
     ns1.local                 | A     | 10.47.73.125
     prod2.local               | A     | 10.0.0.4
     alias2.local              | CNAME | prod2.local
     10.in-addr.arpa           | NS    | ns1.local
     local                     | NS    | ns1.local
     125.73.47.10.in-addr.arpa | PTR   | ns1.local
     4.0.0.10.in-addr.arpa     | PTR   | prod2.local
     10.in-addr.arpa           | SOA   | ns1.local
     local                     | SOA   | ns1.local
    (10 rows)

## pdns::resolver

Run a PowerDNS resolver that contacts the appropriate DNS name servers on
behalf of clients to covert a hostname into an IP or an IP into a hostname.
(The IP address of a DNS resolver is what is specified in /etc/resolv.conf on
Linux/Unix hosts.)

### Parameters

*use_hiera*: look up configuration under 'pdns_resolver' hash in hiera

*listen_address*: IP to listen on. Default: _$::ipaddress_

*dont_query*: IP ranges to exclude from lookups. Default: '127.0.0.0/8, 10.0.0.0/8, 192.168.0.0/16, 172.16.0.0/12, ::1/128'

*forward_zones*: Array of <domain>=<name server IP> values specifying where to
send queries for specific domain.  Default: undef

*forward_domain*: Internal domain name (eg. .local). Default: undef

*reverse_domain*: Reverse .in-addr.arpa domain name for the forward domain (eg.
10.in-addr.arpa).  If forward domain is specified and this is not set then it
is derived from the listen_address.  Default: undef

*nameserver*: The IP address of the authoritative nameserver for the internal
domain name specified in $forward_domain.  Default: $::ipaddress

#### Hiera configuration

Parameters can be specified in hiera configuration files under the
'pdns_resolver' hash:

    pdns_resolver:
      listen_address: ...
      dont_query: ...
      forward_zones: ...
      forward_domain: ...
      reverse_domain: ...
      nameserver: ...

### Examples

Assuming that the local IP address is 192.168.0.72 and there is a authoritative
name server for an internal .local domain at 192.168.0.2:

1) Basic PowerDNS resolver:

    class { 'pdns::resolver': }

which is the same as:

    class { 'pdns::resolver':
      listen_address => 192.168.0.72
    }

3) PowerDNS resolver configured to send queries for a .local domain to the
specified name server:

    class { 'pdns::resolver':
      forward_domain => 'local',
      nameserver     => '192.168.0.2'
    }

which is the same as:

    class { 'pdns::resolver':
      listen_address => 192.168.0.72,
      dont_query     => '127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, ::1/128',
      forward_domain => 'local',
      reverse_domain => '168.192.in-addr.arpa',
      nameserver     => '192.168.0.2'
    }

or:

    class { 'pdns::resolver':
      listen_address => 192.168.0.72,
      dont_query     => '127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, ::1/128',
      forward_zones  => [
        'local=192.168.0.2',
        '168.192.in-addr.arpa=192.168.0.2'
      ]
    }

4) PowerDNS resolver configured to send queries for a .local domain to the
specified name server and network (192.168.0.0/24) for reverse lookups:

    class { 'pdns::resolver':
      forward_domain => 'local',
      forward_zones  => [
        'local=192.168.0.2',
        '0.168.192.in-addr.arpa=192.168.0.2'
      ]
    }

which is the same as:

    class { 'pdns::resolver':
      listen_address => '192.168.0.72',
      dont_query     => '127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, ::1/128',
      forward_zones  => [
        'local=192.168.0.2',
        '0.168.192.in-addr.arpa=192.168.0.2'
      ]
    }

or:

    class { 'pdns::resolver':
      listen_address => '192.168.0.72',
      dont_query     => '127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, ::1/128',
      forward_domain => 'local',
      reverse_domain => '0.168.192.in-addr.arpa',
      nameserver     => '192.168.0.2',
    }

## Support

License: Apache License, Version 2.0

GitHub URL: https://github.com/erwbgy/puppet-pdns
