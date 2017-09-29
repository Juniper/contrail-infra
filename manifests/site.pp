# make sure we do the minimum configuration for all nodes that
# join our puppetmaster (set-up accounts, common packages etc.)
node default {
  class { '::opencontrail_ci::server': }
}

node 'ci-puppetmaster2.opencontrail.org' {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::puppetmaster': }
}

node 'puppetdb2.opencontrail.org' {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::puppetdb': }
}

node 'logs2.opencontrail.org' {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::logserver':
    logserver_ssl_key  => hiera('logserver_ssl_key'),
    logserver_ssl_cert => hiera('logserver_ssl_cert'),
  }
  accounts::user { 'zuul':
    ensure        => present,
    comment       => 'Zuul Launcher',
    purge_sshkeys => true,
    sshkeys       => [ hiera('zuul_ssh_public_key'), ]
  }
}

node 'zuulv3.opencontrail.org' {
  $gerrit_server        = 'review2.opencontrail.org'
  # TODO: create user zuul3 in Gerrit and upload the key
  $gerrit_user          = 'zuul3'
  $gerrit_ssh_host_key  = hiera('gerrit_ssh_rsa_pubkey')
  # TODO: create keypair for zuul
  $zuul_ssh_private_key = hiera('zuul_ssh_private_key')
  $zuul_url             = "http://${::fqdn}/p"
  $git_email            = 'zuul@opencontrail.org'
  $git_name             = 'OpenContrail Zuul'
  # This is current name of openstack-infra/zuul branch.
  $revision             = 'feature/zuulv3'

  class { '::project_config':
    url      => hiera('opencontrail_ci::project_config_repo'),
    revision => 'master',
  }

  # NOTE(pabelanger): We call ::zuul directly, so we can override all in one
  # settings.
  # XXX: It seems there is not a lot of things here
  # to abstract to opencontrail_ci module. Need to revisit.
  class { '::zuul':
    gerrit_server                => $gerrit_server,
    gerrit_user                  => $gerrit_user,
    zuul_ssh_private_key         => $zuul_ssh_private_key,
    git_email                    => $git_email,
    git_name                     => $git_name,
    revision                     => $revision,
    python_version               => 3,
    zookeeper_hosts              => 'nodepool.opencontrail.org:2181',
    disk_limit_per_job           => 1024,
    zuulv3                       => true,
    connections                  => hiera('zuul_connections', []),
    zuul_status_url              => 'http://127.0.0.1:8001/opencontrail',

    # TODO: test with self-gen certs before rolling out production.
    #gearman_client_ssl_cert      => hiera('gearman_client_ssl_cert'),
    #gearman_client_ssl_key       => hiera('gearman_client_ssl_key'),
    #gearman_server_ssl_cert      => hiera('gearman_server_ssl_cert'),
    #gearman_server_ssl_key       => hiera('gearman_server_ssl_key'),
    #gearman_ssl_ca               => hiera('gearman_ssl_ca'),
    #proxy_ssl_cert_file_contents => hiera('zuul_ssl_cert_file_contents'),
    #proxy_ssl_key_file_contents  => hiera('zuul_ssl_key_file_contents'),

    proxy_ssl_cert_file_contents => hiera('proxy_ssl_cert_file_contents'),
    proxy_ssl_key_file_contents  => hiera('proxy_ssl_key_file_contents'),
  }

  class { '::zuul::scheduler':
    layout_dir     => $::project_config::zuul_layout_dir,
    require        => $::project_config::config_dir,
    python_version => 3,
    # TODO: enable mysql or not?
    use_mysql      => false,
  }

  class { '::zuul::web': }
  class { '::zuul::executor': }
}

node 'nodepool.opencontrail.org' {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::nodepool_launcher': }
}

node /^zuul-merger.*$/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::zuul_merger':
    gearman_server => '1.1.1.39',
  }
}

