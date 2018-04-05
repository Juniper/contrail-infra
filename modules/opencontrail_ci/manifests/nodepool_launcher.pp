class opencontrail_ci::nodepool_launcher(
  $cloud_credentials = $::opencontrail_ci::params::cloud_credentials,
  $statsd_host       = $::nodepool::statsd_host
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

  file { '/opt/nodepool-inject-secrets.py':
    source => 'puppet:///modules/opencontrail_ci/nodepool-inject-secrets.py',
    owner  => 'root',
    group  => 'root',
  }

  exec {'nodepool-inject-secrets':
    command     => 'python /opt/nodepool-inject-secrets.py /etc/nodepool/nodepool.yaml.tmpl rhel-7 > /etc/nodepool/nodepool.yaml',
    environment => [
      "DINJ_REG_USER=${::nodepool::rhel_username}",
      "DINJ_REG_PASSWORD=${::nodepool::rhel_password}",
      "DINJ_REG_POOL_ID=${::nodepool::rhel_pool_id}",
      ],
    logoutput   => false,
    require     => File['/opt/nodepool-inject-secrets.py'],
  }

  file { '/etc/nodepool/nodepool.yaml.tmpl':
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
    notify  => Exec['nodepool-inject-secrets'],
  }

  class { '::nodepool::launcher':
    statsd_host   => $::nodepool::statsd_host,
  }

}
