# puppet-pdns

Manage PowerDNS configuration using Puppet

Run either a PowerDNS name server or a PowerDNS resolver, making it easy to use
an internal domain.

## pdns::nameserver

Run a PowerDNS name server to authoritatively answer hostname/IP queries from DNS
resolvers for a specific set of domains managed by the name server.

### Parameters

*use_hiera*: look up configuration under 'pdns_nameserver' hash in hiera. Default: _true_

*backend*: database backend to use - one of: _sqlite_ or _postgresql_. Default: _sqlite_.

*listen_address*: IP to listen on. Default: _$::ipaddress_

*forward_domain*: Internal domain name (eg. .local). Default: undef

*reverse_domain*: Reverse .in-addr.arpa domain name for the forward domain (eg.
10.in-addr.arpa).  If forward domain is specified and this is not set then it
is derived from the listen_address.  Default: undef

#### Hiera configuration

Parameters can be specified in hiera configuration files under the
'pdns nameserver' hash:

Example:

    pdns:
      nameserver:
        backend:        'sqlite'
        listen_address: '192.168.0.3'
        forward_domain: 'local'

### Examples

In_puppet node config we just:

    include pdns::nameserver

Assuming that the primary IP address is a 10.17.0.1:

1) PowerDNS name server with SQLite backend

No hiera config or hiera config:

    pdns:
      nameserver:
        backend:        'sqlite'

which is the same as:

    pdns:
      nameserver:
        backend:        'sqlite'
        listen_address: '10.17.0.1'

2) PowerDNS name server with Postgresql backend:

Hiera config:

    pdns:
      nameserver:
        backend:        'postgresql'

which is the same as:

    pdns:
      nameserver:
        backend:        'postgresql'
        listen_address: '10.17.0.1'

3) PowerDNS name server configured with an internal .local domain:

Hiera config:

    pdns:
      nameserver:
        forward_domain: 'local'

which is the same as:

    pdns:
      nameserver:
        backend:        'sqlite',
        listen_address: '10.17.0.1',
        forward_domain: 'local',
        reverse_domain: '10.in-addr.arpa',

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

*use_hiera*: look up configuration under the 'pdns resolver' hash in hiera. Default: _true_

*listen_address*: IP to listen on. Default: _$::ipaddress_

*dont_query*: IP ranges to exclude from lookups. Default: '127.0.0.0/8, 10.0.0.0/8, 192.168.0.0/16, 172.16.0.0/12, ::1/128'

*forward_zones*: Array of <domain>=<name server IPs> values specifying where to
send queries for specific domain.  Default: undef

*forward_domain*: Internal domain name (eg. .local). Default: undef

*reverse_domain*: Reverse .in-addr.arpa domain name for the forward domain (eg.
10.in-addr.arpa).  If forward domain is specified and this is not set then it
is derived from the listen_address.  Default: undef

*nameservers*: Comma-separated list of the IP addresses of the authoritative nameservers for the internal
domain name specified in $forward_domain.  Default: $::ipaddress

#### Hiera configuration

Parameters can be specified in hiera configuration files under the
'pdns_resolver' hash:

Example:

    pdns:
      resolver:
        listen_address: '127.0.0.1'
        forward_domain: 'local'
        nameservers:     '192.168.0.3,192.168.0.4'

### Examples

In_puppet node config we just:

    include pdns::resolver

Assuming that the local IP address is 192.168.0.72 and there is a authoritative
name server for an internal .local domain at 192.168.0.2:

1) Basic PowerDNS resolver:

No hiera config which is the same as:

    pdns:
      resolver:
        listen_address: 192.168.0.72

3) PowerDNS resolver configured to send queries for a .local domain to the
specified name server:

Hiera config:

    pdns:
      resolver:
        forward_domain: 'local',
        nameservers:    '192.168.0.2'

which is the same as:

    pdns:
      resolver:
        listen_address: '192.168.0.72'
        dont_query:     '127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, ::1/128'
        forward_domain: 'local'
        reverse_domain: '168.192.in-addr.arpa'
        nameservers:    '192.168.0.2'

or:

    pdns:
      resolver:
        listen_address: '192.168.0.72'
        dont_query:     '127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, ::1/128'
        forward_zones:
          - 'local=192.168.0.2'
          - '168.192.in-addr.arpa=192.168.0.2'

4) PowerDNS resolver configured to send queries for a .local domain to the
specified name server and network (192.168.0.0/24) for reverse lookups:

Hiera config:

    pdns:
      resolver:
        forward_domain: 'local'
        forward_zones:
          - 'local=192.168.0.2'
          - '0.168.192.in-addr.arpa=192.168.0.2'

which is the same as:

    pdns:
      resolver:
        listen_address: '192.168.0.72'
        dont_query:     '127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, ::1/128'
        forward_zones:
          - 'local=192.168.0.2'
          - '0.168.192.in-addr.arpa=192.168.0.2'

or:

    pdns:
      resolver:
        listen_address: '192.168.0.72'
        dont_query:     '127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, ::1/128'
        forward_domain: 'local'
        reverse_domain: '0.168.192.in-addr.arpa'
        nameservers:     '192.168.0.2'

## Testing

Tests are implemented using RSpec, rspec-puppet and puppetlabs_spec_helper.  To
run them you will first need to install puppetlabs_spec_helper:

    # gem install puppetlabs_spec_helper

Then switch to the module directory and run rake:

    $ rake
    rake build            # Build puppet module package
    rake clean            # Clean a built module package
    rake coverage         # Generate code coverage information
    rake help             # Display the list of available rake tasks
    rake lint             # Check puppet manifests with puppet-lint
    rake spec             # Run spec tests in a clean fixtures directory
    rake spec_clean       # Clean up the fixtures directory
    rake spec_prep        # Create the fixtures directory
    rake spec_standalone  # Run spec tests on an existing fixtures directory

    $ rake spec
    /usr/bin/ruby -S rspec spec/classes/pdns__resolver_spec.rb spec/classes/pdns__nameserver_spec.rb spec/classes/pdns__resolver__config_spec.rb spec/classes/pdns__nameserver__config_spec.rb --color
    ...............
    
    Finished in 5.19 seconds
    15 examples, 0 failures

## Support

License: Apache License, Version 2.0

GitHub URL: https://github.com/erwbgy/puppet-pdns
