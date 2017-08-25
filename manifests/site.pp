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
  class { '::opencontrail_ci::server': }
  class { '::apache':
    default_vhost => false,
  }
  apache::vhost { 'logs2.opencontrail.org non-ssl':
    servername      => 'logs2.opencontrail.org',
    port            => '80',
    log_level       => 'warn',
    error_log_file  => 'error_logs2.opencontrail.org.log',
    access_log_file => 'access_logs2.opencontrail.org.log',
    docroot         => '/var/www/logs',
    redirect_status => 'permanent',
    redirect_dest   => 'https://logs2.opencontrail.org/',
  }
  apache::vhost { 'logs2.opencontrail.org ssl':
    servername      => 'logs2.opencontrail.org',
    port            => '443',
    log_level       => 'warn',
    access_log_file => 'ssl_access_logs2.opencontrail.org.log',
    error_log_file  => 'ssl_error_logs2.opencontrail.org.log',
    docroot         => '/var/www/logs',
    ssl             => true,
    ssl_cert        => '/etc/ssl/private/logs2.opencontrail.org.crt',
    ssl_key         => '/etc/ssl/private/logs2.opencontrail.org.key',
  }
}

node 'zl01.dev.opencontrail.org' {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::zuul_launcher':
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
        ansible_username => 'ubuntu',
      },
      {
        name             => 'ci-slave-ubuntu14',
        host             => '192.168.1.77',
        description      => '',
        labels           => 'ci-oc-slave-ubuntu14',
        ansible_username => 'jenkins',
      },
    ]
  }
}


node /^zl\d+\.opencontrail\.org$/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::zuul_launcher':
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
  class { '::opencontrail_ci::zuul': }
}
