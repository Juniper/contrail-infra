# make sure we do the minimum configuration for all nodes that
# join our puppetmaster (set-up accounts, common packages etc.)
node default {
  class { '::opencontrail_ci::server': }
}

node /ci-puppetmaster2?.opencontrail.org/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::puppetmaster': }
}

node /puppetdb2?.opencontrail.org/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::puppetdb': }
}

node /logs2?.opencontrail.org/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::logserver':
    logserver_ssl_key  => hiera('logserver_ssl_key'),
    logserver_ssl_cert => hiera('logserver_ssl_cert'),
  }
}

node /zuulv3(-dev)?.opencontrail.org/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::zuul_scheduler': }
  class { '::opencontrail_ci::zuul_merger': }
  class { '::opencontrail_ci::zookeeper': }
}

node /nl\d+(-dev|-jnpr)?.opencontrail.org/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::nodepool_launcher': }
}

node 'nl03-dev.opencontrail.org' {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::zuul_executor': }
  class { '::opencontrail_ci::zuul_scheduler': }
  class { '::opencontrail_ci::nodepool_launcher': }
  class { '::opencontrail_ci::zuul_merger': }
  # this is here because the zookeeper address is fixed in project-config repo and we want to
  # point this nodepool it to the zuulv3-dev.o.o server here
  host { 'zookeeper_host_entry':
    ensure => present,
    name   => 'nodepool.opencontrail.org',
    ip     => '148.251.5.89',
  }
  host { 'gearman_host_entry':
    ensure => present,
    name   => 'zuulv3-dev.opencontrail.org',
    ip     => '148.251.5.89',
  }
}

node /nb\d+(-dev|-jnpr)?.opencontrail.org/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::nodepool_builder': }
}

node /ze\d+(-dev|-jnpr)?.opencontrail.org/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::zuul_executor': }
}
