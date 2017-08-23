class opencontrail_ci::zuul(
  $layout_dir = '/etc/project-config/zuul',
){

  class { '::project_config':
    url => 'https://github.com/kklimonda/contrail-project-config',
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
    require => $::project_config::config_dir,
  }

}
