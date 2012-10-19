class pdns::nameserver::install {
  realize( Package[ 'pdns', 'coreutils', 'bash' ] )
  if $pdns::nameserver::backend == 'postgresql' {
    realize( Package[ 'postgresql', 'postgresql-server', 'pdns-backend-postgresql' ])
    exec { 'pdns-dbsetup':
      command     => '/etc/pdns/dbsetup.sh',
      require     => Class['pdns::nameserver::config'],
      subscribe   => Package[ 'postgresql', 'postgresql-server', 'pdns-backend-postgresql' ],
      refreshonly => true,
    }
  }
  elsif $pdns::nameserver::backend == 'sqlite' {
    realize( Package[ 'sqlite', 'pdns-backend-sqlite' ] )
    exec { 'pdns-dbsetup':
      command     => '/etc/pdns/dbsetup.sh',
      require     => Class['pdns::nameserver::config'],
      subscribe   => Package['sqlite', 'pdns-backend-sqlite'],
      refreshonly => true,
    }
  }
}
