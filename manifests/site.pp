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
  class { '::opencontrail_ci::zuul_scheduler': }
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

