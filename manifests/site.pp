# make sure we do the minimum configuration for all nodes that
# join our puppetmaster (set-up accounts, common packages etc.)
node default {
  class { '::opencontrail_ci::server': }
}

node /puppetmaster-ttu.opencontrail.org/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::puppetmaster': }
}

node /puppetdb-ttu.opencontrail.org/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::puppetdb': }
}

node /logs-ttu.opencontrail.org/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::logserver': }
}

node /zuulv3-ttu.opencontrail.org/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::zuul_scheduler': }
  class { '::opencontrail_ci::zuul_merger': }
  class { '::opencontrail_ci::zookeeper': }
}

node /nl\d+-ttu.opencontrail.org/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::nodepool_launcher': }
}

node /nb\d+-ttu.opencontrail.org/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::nodepool_builder': }
}

node /ze\d+-ttu.opencontrail.org/ {
  class { '::opencontrail_ci::server': }
  class { '::opencontrail_ci::zuul_executor': }
}
