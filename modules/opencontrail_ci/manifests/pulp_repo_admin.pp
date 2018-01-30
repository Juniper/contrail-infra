define opencontrail_ci::pulp_repo_admin (
  $username      = undef,
  $password      = undef,
  $osuser        = $title,
  $osuser_home   = undef,
) {

  file { "/${osuser_home}/.pulp":
    ensure => directory,
    owner  => $osuser,
    group  => $osuser,
    mode   => '0700',
  }

  file { "/${osuser_home}/.pulp/admin.conf":
    ensure  => file,
    owner   => $osuser,
    group   => $osuser,
    mode    => '0600',
    content => template('opencontrail_ci/pulp_admin_home.conf.erb'),
    require => File["/${osuser_home}/.pulp"],
  }

  exec { "pulp-${osuser}-admin-login":
    command => "su -c 'pulp-admin login -u ${username} -p ${password}' ${osuser}",
    path    => '/bin',
    creates => "/${osuser_home}/.pulp/user-cert.pem",
  }

}
