class opencontrail_ci::logserver (
  $logserver_ssl_key = undef,
  $logserver_ssl_cert = undef,
  $zuul_jobs_stats = undef,
  $docroot = '/var/www/logs/',
  $static_docroot = '/var/www/static/',
  $template = 'opencontrail_ci/logserver.vhost.erb',
  $cert_file = "/etc/ssl/private/${::clientcert}.crt",
  $key_file = "/etc/ssl/private/${::clientcert}.key",
  $logfiles_ttl = 30,
) inherits opencontrail_ci::params {

  firewall { '200 accept all to 80 for Apache2':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }

  firewall {'201 accept all to 443 for Apache2':
    proto  => 'tcp',
    dport  => '443',
    action => 'accept',
  }

  accounts::user { 'zuul':
    ensure        => present,
    comment       => 'Zuul Launcher',
    purge_sshkeys => true,
    sshkeys       => [ hiera('zuul_ssh_public_key') ],
  }

  accounts::user { 'zuul-win':
    ensure        => present,
    comment       => 'Windows CI Zuulv2',
    purge_sshkeys => true,
    sshkeys       => [ hiera('zuul_win_ssh_public_key') ],
  }

  accounts::user { 'jenkins':
    ensure        => present,
    comment       => 'Windows CI Jenkins',
    purge_sshkeys => true,
    sshkeys       => [ hiera('jenkins_ssh_public_key') ],
  }

  vcsrepo { '/opt/os_loganalyze':
    ensure   => latest,
    provider => 'git',
    revision => 'a0a4cadabdc9757a12c8c9c42f6ac0e1fbe86905',
    source   => 'https://git.openstack.org/openstack-infra/os-loganalyze',
  }

  package { 'python-pip':
    ensure => installed,
    notify => Exec['install_os_loganalyze'],
  }

  package { 'python-setuptools':
    ensure => installed,
    notify => Exec['install_os_loganalyze'],
  }

  exec { 'install_os_loganalyze':
    command     => 'pip install -U /opt/os_loganalyze',
    path        => '/usr/local/bin:/usr/bin:/bin/',
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/os_loganalyze'],
    require     => [
        Package['python-pip'],
        Package['python-setuptools'],
    ],
  }

  package { 'jq':
    ensure => installed,
  }

  vcsrepo { '/opt/zuul-jobs-stats':
    ensure   => absent,
  }

  file { '/opt/zuul-jobs-stats/settings.ini':
    ensure  => absent,
  }

  file { '/opt/zuul-jobs-stats/cron-config.sh':
    ensure  => absent,
  }

  file { '/etc/logrotate.d/zuul-jobs-stats':
    ensure  => absent,
  }

  cron { 'zuul-jobs-stats':
    ensure => absent,
  }

  file { $key_file:
    owner   => 'root',
    group   => 'ssl-cert',
    mode    => '0440',
    content => $logserver_ssl_key,
    notify  => Service['httpd'],
    require => Package['httpd'],
  }

  file { $cert_file:
    owner   => 'root',
    group   => 'ssl-cert',
    mode    => '0440',
    content => $logserver_ssl_cert,
    notify  => Service['httpd'],
    require => Package['httpd'],
  }

  file { $docroot:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '1777',
    notify => Service['httpd'],
  }

  file { $static_docroot:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '1777',
    notify => Service['httpd'],
  }

  class { '::httpd::mod::wsgi': }
  ::httpd::mod { 'rewrite': }

  ::httpd::vhost { $::clientcert:
    port       => 443,
    docroot    => $docroot,
    priority   => '0',
    ssl        => true,
    template   => $template,
    vhost_name => $::clientcert,
    require    => [
        File[$docroot],
        File[$static_docroot],
        File[$cert_file],
        File[$key_file],
        Httpd::Mod['rewrite'],
        Httpd::Mod['wsgi'],
    ],
  }

  file { '/opt/opencontrail_ci':
      ensure => directory,
      mode   => '0700',
      owner  => 'root',
  }

  file { '/opt/opencontrail_ci/log_curator.sh':
    ensure  => file,
    source  => 'puppet:///modules/opencontrail_ci/logs/log_curator.sh',
    mode    => '0700',
    owner   => 'root',
    require => [
        File['/opt/opencontrail_ci/']
    ],
  }

  cron { 'log_curator':
    command  => "/opt/opencontrail_ci/log_curator.sh -p ${docroot} -d ${logfiles_ttl}",
    user     => 'root',
    minute   => '0',
    hour     => '0',
    monthday => '*/1',
    require  => [
        File['/opt/opencontrail_ci/log_curator.sh']
    ],
  }

  class { '::opencontrail_ci::acid':
      acid_db_host         => hiera('acid_db_host'),
      acid_db_name         => hiera('acid_db_name'),
      acid_db_user         => hiera('acid_db_user'),
      acid_db_pass         => hiera('acid_db_pass'),
      acid_zuul_url        => 'http://zuulv3.opencontrail.org/',
      acid_log_url         => $::fqdn,
      acid_ssh_public_key  => $::acid_ssh_public_key,
      acid_ssh_private_key => $::acid_ssh_private_key,
      acid_manager_tenant  => 'opencontrail',
      acid_manager_host    => 'zuulv3.opencontrail.org',
      acid_manager_user    => 'acid',
      acid_manager_project => 'Juniper/contrail-analytics',
  }
}
