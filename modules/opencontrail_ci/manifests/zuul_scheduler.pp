class opencontrail_ci::zuul_scheduler(
  $gearman_allowed_clients = [],
) inherits opencontrail_ci::params {
  class { '::project_config':
    url      => $::opencontrail_ci::params::project_config_repo,
    revision => 'master',
  }

  firewall { '200 accept all to 80 for Apache2':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }

  firewall { '201 accept all to 443 for Apache2':
    proto  => 'tcp',
    dport  => '443',
    action => 'accept',
  }

  package { 'python3-mysqldb':
      ensure => installed,
  }

  include ::zuul::known_hosts
  if ! defined(Class['zuul']) {
    class { '::zuul':
      statsd_host => $::zuul::statsd_host,
    }
  }
  class { '::zuul::web': }
  class { '::zuul::scheduler':
    layout_dir => $::project_config::zuul_layout_dir,
    require    => [
        $::project_config::config_dir,
        Package['python3-mysqldb'],
    ],
  }
  opencontrail_ci::gearman_allow_client { $gearman_allowed_clients: }

  file { '/etc/zuul/gearman-logging.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('opencontrail_ci/gearman-logging.conf.erb'),
  }

}
