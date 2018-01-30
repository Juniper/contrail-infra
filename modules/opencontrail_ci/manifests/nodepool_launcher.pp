class opencontrail_ci::nodepool_launcher(
  $cloud_credentials = $::opencontrail_ci::params::cloud_credentials
) inherits opencontrail_ci::params {

  if ! defined(Class['project_config']) {
    class { '::project_config':
      url      =>  $::opencontrail_ci::params::project_config_repo,
      revision =>  'master',
    }
  }

  class { '::nodepool':
    require => Class['project_config'],
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

  file { '/home/nodepool/.config/openstack/clouds.yaml':
    ensure  => present,
    owner   => 'nodepool',
    group   => 'nodepool',
    mode    => '0400',
    content => template('opencontrail_ci/nodepool/clouds.yaml.erb'),
    require => File['/home/nodepool/.config'],
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
