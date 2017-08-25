class opencontrail_ci::logserver (
  $logserver_ssl_key = undef,
  $logserver_ssl_cert = undef,
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

  file { "/etc/ssl/private/${::clientcert}.key":
    owner   => 'root',
    group   => 'ssl-cert',
    mode    => '0440',
    content => $logserver_ssl_key,
    notify  => Class['Apache::Service'],
  }

  file { "/etc/ssl/private/${::clientcert}.crt":
    owner   => 'root',
    group   => 'ssl-cert',
    mode    => '0440',
    content => $logserver_ssl_cert,
    notify  => Class['Apache::Service'],
  }

  class { '::apache':
    default_vhost => false,
  }

  apache::vhost { "${::clientcert} non-ssl":
    servername      => $::clientcert,
    port            => '80',
    log_level       => 'warn',
    error_log_file  => "error_${::clientcert}.log",
    access_log_file => "access_${::clientcert}.log",
    docroot         => '/var/www/logs',
    redirect_status => 'permanent',
    redirect_dest   => "https://${::clientcert}/",
  }

  apache::vhost { "${::clientcert} ssl":
    servername      => $::clientcert,
    port            => '443',
    log_level       => 'warn',
    access_log_file => "ssl_access_${::clientcert}.log",
    error_log_file  => "ssl_error_${::clientcert}log",
    docroot         => '/var/www/logs',
    ssl             => true,
    ssl_cert        => "/etc/ssl/private/${::clientcert}.crt",
    ssl_key         => "/etc/ssl/private/${::clientcert}.key",
    require         => [
        File["/etc/ssl/private/${::clientcert}.key"],
        File["/etc/ssl/private/${::clientcert}.crt"],
    ]
  }
}
