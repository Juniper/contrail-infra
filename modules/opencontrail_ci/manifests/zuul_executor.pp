class opencontrail_ci::zuul_executor inherits opencontrail_ci::params {

  include ::zuul::known_hosts

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

  class { '::zuul::executor': }
}
