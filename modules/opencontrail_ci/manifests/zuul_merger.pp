class opencontrail_ci::zuul_merger(
  $gearman_server = '127.0.0.1',
) inherits opencontrail_ci::params {

  class { '::zuul':
    gearman_server       => $gearman_server,
    gerrit_server        => 'review2.opencontrail.org',
    gerrit_user          => 'zuulv3',
    zuul_ssh_private_key => hiera('zuul_ssh_private_key'),
    connections          => hiera('zuul_connections', []),
    git_email            => 'zuul@opencontrail.org',
    git_name             => 'OpenContrail Zuul',
    revision             => 'feature/zuulv3',
    python_version       => 3,
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
