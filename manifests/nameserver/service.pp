class pdns::nameserver::service {
  service { 'pdns':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => Class['pdns::nameserver::config'],
  }
}
