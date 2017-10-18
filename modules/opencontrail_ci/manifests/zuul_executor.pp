class opencontrail_ci::zuul_executor inherits opencontrail_ci::params {

  include ::zuul::known_hosts

  if ! defined(Class['zuul']) {
    class { '::zuul': }
  }

  class { '::zuul::executor': }
}
