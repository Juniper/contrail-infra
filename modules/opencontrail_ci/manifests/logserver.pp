class opencontrail_ci::logserver (
  $logserver_ssl_key = undef,
  $logserver_ssl_cert = undef,
  $zuul_jobs_stats = undef,
  $docroot = '/var/www/logs/',
  $template = 'opencontrail_ci/logserver.vhost.erb',
  $cert_file = "/etc/ssl/private/${::clientcert}.crt",
  $key_file = "/etc/ssl/private/${::clientcert}.key",
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
    ensure   => latest,
    provider => 'git',
    revision => 'master',
    source   => 'https://github.com/codilime/zuul-jobs-stats',
  }

  exec { 'install_zuul-jobs-stats':
    command   => 'pip install -r requirements.txt',
    path      => '/usr/local/bin:/usr/bin:/bin/',
    cwd       => '/opt/zuul-jobs-stats',
    subscribe => Vcsrepo['/opt/zuul-jobs-stats'],
    require   => Package['python-pip'],
  }

  file { '/opt/zuul-jobs-stats/settings.ini':
    ensure  => file,
    content => template('opencontrail_ci/zuul-jobs-stats-settings.ini.erb'),
    mode    => '0600',
    owner   => 'root',
  }

  file { '/opt/zuul-jobs-stats/cron-config.sh':
    ensure  => file,
    content => inline_template('export LOGS_DIR=<%= @docroot %>'),
    mode    => '0600',
    owner   => 'root',
  }

  cron { 'zuul-jobs-stats':
    command => 'bash /opt/zuul-jobs-stats/cron.sh',
    user    => 'root',
    hour    => '*/6',
    require => [
        File['/opt/zuul-jobs-stats/cron-config.sh'],
        File['/opt/zuul-jobs-stats/settings.ini'],
        Package['jq'],
    ],
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
        File[$cert_file],
        File[$key_file],
        Httpd::Mod['rewrite'],
        Httpd::Mod['wsgi'],
    ],
  }
}
