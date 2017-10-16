class opencontrail_ci::zuul_merger inherits opencontrail_ci::params {

  if ! defined(Class['zuul']) {
    class { '::zuul': }
  }

  class { '::zuul::merger': }

  file { '/home/zuul/.ssh':
    ensure  => directory,
    owner   => 'zuul',
    group   => 'zuul',
    mode    => '0700',
    require => Class['::zuul'],
  }

  create_resources(sshkey, hiera('zuul_ssh_host_keys'))
}
