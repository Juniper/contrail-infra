class opencontrail_ci::pulp_repo inherits opencontrail_ci::params {

  include ::epel

  class { '::pulp':
    require         => Class['epel'],
    enable_docker   => true,
    enable_rpm      => true,
  }

  firewall { '100 accept all to 80 - repos over http ':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }

  firewall { '100 accept all to 443 - repos over https + Pulp API ':
    proto  => 'tcp',
    dport  => '443',
    action => 'accept',
  }
}
