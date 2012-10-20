class pdns::resolver::install {
  package { [
    'pdns-recursor'
  ]:
    ensure => installed,
  }
}
