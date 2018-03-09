class opencontrail_ci::zuul_executor inherits opencontrail_ci::params {

  include ::zuul::known_hosts

  package { 'python3-mysqldb':
      ensure => installed,
  }

  package { 'mysql-client':
      ensure => installed,
  }

  firewall { '100 accept all to 3306 - build number db':
    proto  => 'tcp',
    dport  => '3306',
    action => 'accept',
  }

  class { '::project_config':
    url      => $::opencontrail_ci::params::project_config_repo,
    revision => 'master',
  }

  if ! defined(Class['zuul']) {
    class { '::zuul':
      statsd_host => $::zuul::statsd_host,
    }
  }

  package { "python3-jmespath":
    ensure => present,
    before => Class['::zuul::executor'],
  }

  class { '::zuul::executor': }
}
