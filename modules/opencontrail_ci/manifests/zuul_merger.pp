class opencontrail_ci::zuul_merger inherits opencontrail_ci::params {
  if ! defined(Class['zuul']) {
    class { '::zuul':
      statsd_host => $::zuul::statsd_host,
    }
  }
  include ::zuul::known_hosts
  class { '::zuul::merger': }
}
