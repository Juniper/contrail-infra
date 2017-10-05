class opencontrail_ci::logserver (
  $logserver_ssl_key = undef,
  $logserver_ssl_cert = undef,
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
    ],
  }
}
