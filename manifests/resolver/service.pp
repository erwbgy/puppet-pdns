class pdns::resolver::service {
  service { 'pdns-recursor':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => Class['pdns::resolver::config'],
  }
}
