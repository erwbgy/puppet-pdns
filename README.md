# puppet-pdns

Manage PowerDNS configuration using Puppet

## Examples

### PowerDNS nameserver with Postgresql backend

```
   class { 'pdns::nameserver':
     type    => 'nameserver',
     backend => 'postgresql'
   }
```

### PowerDNS nameserver with SQLite backend

```
   class { 'pdns::nameserver':
     type    => 'nameserver',
     backend => 'sqlite'
   }
```

### PowerDNS resolver

```
   class { 'pdns::resolver':
     listen_address => $::ipaddress_lo,
     dont_query     => '192.168.0.0/16, 172.16.0.0/12, ::1/128',
     forward_zones  => [ 'local=10.5.11.16', '5.10.in-addr.arpa=10.5.11.16' ]
   }
```

License
-------

Apache License, Version 2.0

Support
-------

Please report any issues at https://github.com/erwbgy/puppet-pdns
