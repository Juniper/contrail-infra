# make sure we do the minimum configuration for all nodes that
# join our puppetmaster (set-up accounts, common packages etc.)
node default {
  class { 'opencontrail_ci::server': }
}

node 'ci-puppetmaster2.opencontrail.org' {
  class { 'opencontrail_ci::server': }
  class { 'opencontrail_ci::puppetmaster': }
}

node 'puppetdb2.opencontrail.org' {
  class { 'opencontrail_ci::server': }
  class { 'opencontrail_ci::puppetdb': }
}

node 'zl01.dev.opencontrail.org' {
  class { 'opencontrail_ci::server': }
  class { 'opencontrail_ci::zuul_launcher':
    gearman_server       => 'zuul2.opencontrail.org',
    gerrit_server        => 'review2.opencontrail.org',
    gerrit_user          => 'zuul',
    gerrit_ssh_host_key  => hiera('gerrit_ssh_rsa_pubkey'),
    zuul_ssh_private_key => hiera('zuul_ssh_private_key'),
    accept_nodes         => false,
    nodes                => [
      {
        name             => 'ci-testnode',
        host             => '148.251.5.87',
        description      => '',
        labels           => 'ci-oc-slave-healthcheck',
      },
    ]
  }
}


node /^zl\d+\.opencontrail\.org$/ {
  class { 'opencontrail_ci::server': }
  class { 'opencontrail_ci::zuul_launcher':
    gearman_server       => 'zuul2.opencontrail.org',
    gerrit_server        => 'review2.opencontrail.org',
    gerrit_user          => 'zuul',
    gerrit_ssh_host_key  => hiera('gerrit_ssh_rsa_pubkey'),
    zuul_ssh_private_key => hiera('zuul_ssh_private_key'),
    accept_nodes         => false,
    nodes                => [
      {
        name             => 'cl-sb-win2016',
        host             => '10.7.0.216',
        description      => 'Windows 2016 Static Builder',
        labels           => 'contrail-systest-builder-win',
        ansible_username => 'Tester',
        ansible_password => hiera('zl_static_cl_sb_win2016_password'),
      },
    ]
  }
}

node 'zuul2.opencontrail.org' {
  class { 'opencontrail_ci::zuul': }
}
