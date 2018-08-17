class opencontrail_ci::mirror_update {
  include ::opencontrail_ci::reprepro_mirror


  file { '/usr/local/bin/reprepro-mirror-update':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/opencontrail_ci/reprepro/reprepro-mirror-update.sh',
  }

  ::opencontrail_ci::reprepro { 'ubuntu-reprepro-mirror':
    confdir       => '/etc/reprepro/ubuntu',
    basedir       => '/opt/mirror/ubuntu',
    distributions => 'opencontrail_ci/reprepro/distributions.ubuntu.erb',
    updates_file  => 'puppet:///modules/opencontrail_ci/reprepro/debuntu-updates',
    releases      => ['trusty', 'xenial'],
  }

  cron { 'reprepro ubuntu':
    user        => $user,
    hour        => '*/2',
    minute      => fqdn_rand(45, 'reprepro-ubuntu'),
    command     => 'flock -n /var/run/reprepro/ubuntu.lock reprepro-mirror-update /etc/reprepro/ubuntu mirror.ubuntu >>/var/log/reprepro/ubuntu-mirror.log 2>&1',
    environment => 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
    require     => [
      File['/usr/local/bin/reprepro-mirror-update'],
      ::Opencontrail_ci::Reprepro['ubuntu-reprepro-mirror'],
    ]
  }

  gnupg_key { 'Ubuntu Archive':
    ensure     => present,
    key_id     => '40976EAF437D05B5',
    user       => 'root',
    key_server => 'hkp://keyserver.ubuntu.com:80',
    key_type   => 'public',
  }

  gnupg_key { 'Ubuntu Archive (2012)':
    ensure     => present,
    key_id     => '3B4FE6ACC0B21F32',
    user       => 'root',
    key_server => 'hkp://keyserver.ubuntu.com:80',
    key_type   => 'public',
  }

}
