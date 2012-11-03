class pdns::resolver::install {
  if ! defined(Package['pdns-recursor']) {
    package { 'pdns-recursor': ensure => installed }
  }
}
