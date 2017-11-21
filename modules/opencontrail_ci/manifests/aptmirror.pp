class opencontrail_ci::aptmirror (
  $aptmirror_ssl_key = undef,
  $aptmirror_ssl_cert = undef,
  $docroot = '/var/www/mirror/',
  $package_cache = '/var/spool/apt-mirror'
  $vhost_template = 'opencontrail_ci/aptmirror.vhost.erb',
  $mirror_template = 'opencontrail_ci/aptmirror.mirro.list.erb',
  $cert_file = "/etc/ssl/private/${::clientcert}.crt",
  $key_file = "/etc/ssl/private/${::clientcert}.key",
  $mirror_list = "/etc/apt/mirror.list"
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

  accounts::user { 'apt-mirror':
    ensure        => present,
    comment       => 'apt-mirror cronjob',
  }

  package { 'apt-mirror':
    ensure => installed,
  }

  file { $key_file:
    owner   => 'root',
    group   => 'ssl-cert',
    mode    => '0440',
    content => $aptmirror_ssl_key,
    notify  => Service['httpd'],
    require => Package['httpd'],
  }

  file { $cert_file:
    owner   => 'root',
    group   => 'ssl-cert',
    mode    => '0440',
    content => $aptmirror_ssl_cert,
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

  file { $package_cache:
    ensure => 'directory',
    owner  => 'apt-mirror',
    group  => 'apt-mirror',
    mode   => '1777',
  }

  file { $mirror_list:
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => $mirror_template,
    require => Package['apt-mirror'],
  }

  class { '::httpd::mod::wsgi': }
  ::httpd::mod { 'rewrite': }

  ::httpd::vhost { $::clientcert:
    port       => 443,
    docroot    => $docroot,
    priority   => '0',
    ssl        => true,
    template   => $vhost_template,
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
