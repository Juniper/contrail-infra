class opencontrail_ci::zuul_scheduler inherits opencontrail_ci::params {
  class { '::project_config':
    url      => $::opencontrail_ci::params::project_config_repo,
    revision => 'master',
  }

  class { '::zuul': }
  class { '::zuul::web': }
  class { '::zuul::scheduler':
    layout_dir => $::project_config::zuul_layout_dir,
    require    => $::project_config::config_dir,
  }
}
