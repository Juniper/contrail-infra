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
    zuul_jobs_stats    => hiera('zuul_jobs_stats'),
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

node /nb\d+(-dev|-jnpr)?.opencontrail.org/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::nodepool_builder': }
}

node /ze\d+(-dev|-jnpr)?.opencontrail.org/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::zuul_executor': }
}
