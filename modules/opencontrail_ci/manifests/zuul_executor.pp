class opencontrail_ci::zuul_executor inherits opencontrail_ci::params {

  include ::zuul::known_hosts

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
