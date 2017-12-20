class opencontrail_ci::pulp_repo(
  $pulp_version,
  $pulp_admin_password,
) inherits opencontrail_ci::params {

  include ::docker
  include ::epel

  yumrepo { "pulp-${pulp_version}-stable":
    baseurl  => "https://repos.fedorapeople.org/repos/pulp/pulp/stable/${pulp_version}/\$releasever/\$basearch/",
    descr    => "Pulp ${pulp_version} Production Releases",
    enabled  => true,
    gpgcheck => true,
    gpgkey   => "https://repos.fedorapeople.org/repos/pulp/pulp/GPG-RPM-KEY-pulp-${pulp_version}",
  }

  class { '::pulp':
    require       => Class['epel'],
    enable_docker => true,
    enable_rpm    => true,
    ssl_username  => false,
  }

  class { '::pulp::admin':
    require => Class['pulp'],
  }

  # by default cert is only readable by root:apache, make it available for other
  # users as well
  exec { 'pulp-make-cacert-systemwide':
    command => "cp ${::pulp::ca_cert} /etc/pki/ca-trust/source/anchors/pulp_ca.crt && update-ca-trust enable && update-ca-trust extract",
    path    => '/bin',
    creates => '/etc/pki/ca-trust/source/anchors/pulp_ca.crt',
    require => Class['pulp'],
  }

  accounts::user { 'zuul':
    ensure        => present,
    comment       => 'Zuul Executor',
    home          => '/home/zuul',
    managehome    => true,
    purge_sshkeys => true,
    sshkeys       => [ hiera('zuul_ssh_public_key') ],
  }

  opencontrail_ci::pulp_repo_admin { 'root':
    username    => 'admin',
    password    => $pulp_admin_password,
    osuser      => 'root',
    osuser_home => '/root',
    require     => [ Service['pulp_resource_manager', 'httpd'], Class['pulp::admin'] ],
  }

  opencontrail_ci::pulp_repo_admin { 'zuul':
    username    => 'admin',
    password    => $pulp_admin_password,
    osuser      => 'zuul',
    osuser_home => '/home/zuul',
    require     => [ User['zuul'], Service['pulp_resource_manager', 'httpd'], Class['pulp::admin'] ],
  }

  pulp_rpmrepo { 'opencontrail-tpc':
    ensure        => present,
    display_name  => 'opencontrail-tpc',
    description   => 'Third party packages required for OpenContail build',
    relative_url  => 'opencontrail-tpc',
    serve_http    => true,
    serve_https   => true,
    checksum_type => 'sha256',
    require       => [ Service['pulp_resource_manager', 'httpd'], Class['pulp::admin'] ],
  }

  docker::image { 'registry': }
  docker::run { 'registry':
    image   => 'registry',
    ports   => ['5000:5000'],
    require => Docker::Image['registry'],
  }

  firewall { '100 accept all to 80 - repos over http ':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }

  firewall { '100 accept all to 443 - repos over https + Pulp API ':
    proto  => 'tcp',
    dport  => '443',
    action => 'accept',
  }

  firewall { '102 accept all to 5000 - docker registry':
    proto  => 'tcp',
    dport  => '5000',
    action => 'accept',
  }
}
