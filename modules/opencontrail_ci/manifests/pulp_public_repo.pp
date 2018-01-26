class opencontrail_ci::pulp_public_repo inherits opencontrail_ci::params {

  pulp_rpmrepo { 'opencontrail-thirdparty':
    ensure        => present,
    display_name  => 'opencontrail-thirdparty',
    description   => 'Third party packages required for OpenContrail build',
    relative_url  => 'centos/7/opencontrail-thirdparty/x86_64',
    serve_http    => true,
    serve_https   => true,
    checksum_type => 'sha256',
    require       => [ Service['pulp_resource_manager', 'httpd'], Class['pulp::admin'] ],
  }

  pulp_rpmrepo { 'opencontrail':
    ensure        => present,
    display_name  => 'opencontrail',
    description   => 'OpenContrail nightly',
    relative_url  => 'centos/7/opencontrail/x86_64',
    serve_http    => true,
    serve_https   => true,
    checksum_type => 'sha256',
    require       => [ Service['pulp_resource_manager', 'httpd'], Class['pulp::admin'] ],
  }
}
