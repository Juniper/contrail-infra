class opencontrail_ci::zuul_executor inherits opencontrail_ci::params {

  if ! defined(Class['zuul']) {
    class { '::zuul': }
  }

  class { '::zuul::executor': }
}
