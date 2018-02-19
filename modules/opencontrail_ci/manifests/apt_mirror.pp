class opencontrail_ci::apt_mirror (
  $docroot = '/var/www/html/',
  $package_cache = '/var/spool/apt-mirror',
  $vhost_template = 'opencontrail_ci/apt_mirror.vhost.erb',
  $mirror_list = '/etc/apt/mirror.list'
) inherits opencontrail_ci::params {

  include ::httpd

  firewall { '200 accept all to 80 for Apache2':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }

  accounts::user { 'apt-mirror':
    ensure        => present,
    comment       => 'apt-mirror cronjob',
  }

  package { 'apt-mirror':
    ensure => installed,
  }

  cron { 'apt-mirror':
    command => '/usr/bin/apt-mirror > /var/spool/apt-mirror/var/cron.log',
    user    => 'apt-mirror',
    hour    => 1,
    minute  => 0,
    require => [
        Package['apt-mirror'],
        User['apt-mirror'],
    ],
  }

  file { $docroot:
    ensure => 'directory',
  }

  file { "${docroot}/ubuntu":
    ensure => 'link',
    target => "${package_cache}/mirror/us.archive.ubuntu.com/ubuntu",
    notify => Service['httpd'],
  }

  file { $package_cache:
    ensure => 'directory',
    owner  => 'apt-mirror',
    group  => 'apt-mirror',
    mode   => '0755',
  }

  file { $mirror_list:
    owner   => 'apt-mirror',
    group   => 'apt-mirror',
    mode    => '0655',
    content => template('opencontrail_ci/apt_mirror.mirror.list.erb'),
    require => Package['apt-mirror'],
  }

  ::httpd::vhost { $::clientcert:
    port       => 80,
    docroot    => $docroot,
    priority   => '0',
    ssl        => false,
    template   => $vhost_template,
    vhost_name => $::clientcert,
    require    => [
        File[$docroot],
    ],
  }
}
