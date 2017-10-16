class opencontrail_ci::nodepool_launcher inherits opencontrail_ci::params {

  if ! defined(Class['project_config']) {
    class { '::project_config':
      url      =>  $::opencontrail_ci::params::project_config_repo,
      revision =>  'master',
    }
  }

  class { '::nodepool':
    mysql_root_password      => hiera('mysql_root_password'),
    mysql_password           => hiera('mysql_password'),
    git_source_repo          => 'https://github.com/kklimonda/nodepool',
    revision                 => 'feature/zuulv3',
    statsd_host              => undef,
    nodepool_ssh_private_key => hiera('nodepool_ssh_private_key'),
    scripts_dir              => $::project_config::nodepool_scripts_dir,
    require                  => $::project_config::config_dir,
    install_mysql            => false,
    install_nodepool_builder => false,
    python_version           => 3,
  }

  file { '/home/nodepool/.config':
    ensure  => directory,
    owner   => 'nodepool',
    group   => 'nodepool',
    require => [
      User['nodepool'],
    ],
  }

  file { '/home/nodepool/.config/openstack':
    ensure  => directory,
    owner   => 'nodepool',
    group   => 'nodepool',
    require => [
      File['/home/nodepool/.config'],
    ],
  }

  file { '/etc/nodepool/nodepool.yaml':
    ensure  => present,
    source  => $::project_config::nodepool_config_file,
    owner   => 'nodepool',
    group   => 'root',
    mode    => '0400',
    require => [
      File['/etc/nodepool'],
      User['nodepool'],
      Class['project_config'],
    ],
  }

  class { '::nodepool::launcher':
    statsd_host   => undef,
    statsd_prefix => undef,
  }

}
