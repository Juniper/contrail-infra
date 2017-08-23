class opencontrail_ci::zuul(
  $layout_dir = '/etc/project-config/zuul',
) inherits opencontrail_ci::params {

  class { '::project_config':
    url      => $::project_config_repo,
    revision => $::environment,
  }

  file { '/etc/init.d/zuul':
    ensure => present,
    noop   => true,
  }

  exec { 'zuul-reload':
    command     => '/etc/init.d/zuul reload',
    require     => File['/etc/init.d/zuul'],
    refreshonly => true,
  }

  file { '/etc/zuul/layout/':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    notify  => Exec['zuul-reload'],
    require => $::project_config::config_dir,
  }

}
