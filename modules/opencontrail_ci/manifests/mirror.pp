class opencontrail_ci::mirror (
  $vhost_name = $::fqdn,
) {

  # Some hosts are mirror01, but we need the host to respond to
  # "mirror."  Re-evaluate this if we end up doing multiple
  # mirrors/load balancing etc.
  $alias_name = regsubst($vhost_name, 'mirrors\d*\.', 'mirrors.')
  if $alias_name != $vhost_name {
    $serveraliases = [$alias_name]
  } else {
    $serveraliases = undef
  }

  $mirror_root = '/opt/mirror'

  $www_base = '/var/www'
  $www_root = "${www_base}/mirror"

  #####################################################
  # Build Apache Webroot
  file { $www_base:
    ensure => directory,
    owner  => root,
    group  => root,
  }

  file { $www_root:
    ensure  => directory,
    owner   => root,
    group   => root,
    require => [
      File[$www_base],
    ]
  }

  # Create the symlink to Ubuntu
  file { "${www_root}/ubuntu":
    ensure  => link,
    target  => "${mirror_root}/ubuntu",
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  file { "${www_root}/robots.txt":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/opencontrail_ci/disallow_robots.txt',
    require => File[$www_root],
  }

  #####################################################
  # Build VHost
  include ::httpd

  file { '/opt/apache_cache':
    ensure => absent,
    force  => true,
  }

  file { '/var/cache/apache2/proxy':
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0755',
    require => Class['httpd']
  }

  if ! defined(Httpd::Mod['rewrite']) {
    httpd::mod { 'rewrite':
      ensure => present,
    }
  }

  if ! defined(Httpd::Mod['substitute']) {
    httpd::mod { 'substitute':
      ensure => present,
    }
  }

  if ! defined(Httpd::Mod['cache']) {
    httpd::mod { 'cache':
      ensure => present,
    }
  }

  if ! defined(Httpd::Mod['cache_disk']) {
    httpd::mod { 'cache_disk':
      ensure => present,
    }
  }

  if ! defined(Httpd::Mod['proxy']) {
    httpd::mod { 'proxy':
      ensure => present,
    }
  }

  if ! defined(Httpd::Mod['proxy_http']) {
    httpd::mod { 'proxy_http':
      ensure => present,
    }
  }

  ::httpd::vhost { $vhost_name:
    port          => 80,
    priority      => '50',
    docroot       => $www_root,
    template      => 'opencontrail_ci/mirror.vhost.erb',
    serveraliases => $serveraliases,
    require       => [
      File[$www_root],
    ]
  }

  # Cache cleanup
  package { 'apache2-utils':
    ensure => present,
  }

  cron { 'apache-cache-cleanup':
    # Clean apache cache once an hour, keep size down to 70GiB.
    minute      => '0',
    hour        => '*',
    command     => 'flock -n /var/run/htcacheclean.lock htcacheclean -n -p /var/cache/apache2/proxy -t -l 70200M > /dev/null',
    environment => 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
    require     => [
      File['/var/cache/apache2/proxy'],
      Package['apache2-utils'],
      ],
  }

  class { '::httpd::logrotate':
    options => [
      'daily',
      'missingok',
      'rotate 7',
      'compress',
      'delaycompress',
      'notifempty',
      'create 640 root adm',
      ],
  }
}
