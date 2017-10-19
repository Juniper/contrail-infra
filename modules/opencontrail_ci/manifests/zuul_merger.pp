class opencontrail_ci::zuul_merger inherits opencontrail_ci::params {
  if ! defined(Class['zuul']) {
    class { '::zuul': }
  }
  include ::zuul::known_hosts
  class { '::zuul::merger': }
}
