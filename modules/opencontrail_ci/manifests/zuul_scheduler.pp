class opencontrail_ci::zuul_scheduler(
  $gearman_allowed_clients = [],
) inherits opencontrail_ci::params {
  class { '::project_config':
    url      => $::opencontrail_ci::params::project_config_repo,
    revision => 'master',
  }

  include ::zuul::known_hosts
  if ! defined(Class['zuul']) {
    class { '::zuul': }
  }
  class { '::zuul::web': }
  class { '::zuul::scheduler':
    layout_dir => $::project_config::zuul_layout_dir,
    require    => $::project_config::config_dir,
  }
  opencontrail_ci::gearman_allow_client { $gearman_allowed_clients: }
}
