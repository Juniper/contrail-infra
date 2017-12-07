class opencontrail_ci::pulp_repo(
  $pulp_version,
) inherits opencontrail_ci::params {

  include ::epel

  yumrepo { "pulp-${pulp_version}-stable":
      baseurl  => "https://repos.fedorapeople.org/repos/pulp/pulp/stable/${pulp_version}/\$releasever/\$basearch/",
      descr    => "Pulp ${pulp_version} Production Releases",
      enabled  => true,
      gpgcheck => true,
      gpgkey   => "https://repos.fedorapeople.org/repos/pulp/pulp/GPG-RPM-KEY-pulp-${pulp_version}",
  }

  class { '::pulp':
    require         => Class['epel'],
    enable_docker   => true,
    enable_rpm      => true,
  }

  class { '::pulp::admin': }

  pulp_rpmrepo { 'opencontrail-tpc':
    display_name     => 'opencontrail-tpc',
    description      => 'Third party packages required for OpenContail build',
    relative_url     => 'opencontrail-tpc',
    serve_http       => true,
    serve_https      => true,
    checksum_type    => 'sha256',
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
}
