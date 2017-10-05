class opencontrail_ci::aptly (
  $vhost = 'repo.opencontrail.org',
  $cert_file = "/etc/ssl/private/logs2.opencontrail.org.crt",
  $key_file = "/etc/ssl/private/logs2.opencontrail.org.key",
) {
  accounts::user { 'aptly':
    ensure        => present,
    comment       => 'Aptly Deb Repo',
    home          => '/var/lib/aptly',
    home_mode     => 0755,
  }

  class { '::aptly::api': 
    user => 'aptly',
  }
  class { '::aptly':
    config => {
        rootDir => "/var/lib/aptly",
    }
  }

  ::httpd::mod { 'proxy_http': ensure => present; }
  ::httpd::mod { 'rewrite': ensure => present; }

  file { '/etc/apache2/htpasswd':
    owner  => 'www-data',
    group  => 'root',
    mode   => '1600',
    content => hiera('htpasswd'),
    notify => Service['httpd'],
  }

  file { '/var/lib/aptly/public/repo.key':
    owner  => 'aptly',
    group  => 'www-data',
    mode   => '1755',
    content => hiera('deb_gpg_public_key'),
  }

  gnupg_key { 'aptly_deb_publish_key':
    key_id     => hiera('deb_gpg_key_id'),
    ensure     => present,
    user       => 'aptly',
    key_content => hiera('deb_gpg_private_key'),
    key_type   => 'private',
  }

  ::httpd::vhost { $vhost:
    port       => 443,
    docroot    => '/var/lib/aptly/public',
    priority   => '0',
    ssl        => true,
    template   => 'opencontrail_ci/aptly.vhost.erb',
    vhost_name => $vhost,
  }
}
