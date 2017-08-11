class opencontrail_ci::puppetdb inherits opencontrail_ci::params {
  class { '::puppetdb':
    manage_firewall => false,
  }

  firewall { '100 accept port 8081 from puppet master':
    dport  => 8081,
    proto  => 'tcp',
    action => 'accept',
  }
}
