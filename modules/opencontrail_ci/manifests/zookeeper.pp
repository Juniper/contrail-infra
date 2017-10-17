class opencontrail_ci::zookeeper(
  $allowed_clients = [],
) inherits opencontrail_ci::params {

  class { '::zookeeper': }
  opencontrail_ci::zookeeper_allow_client { $allowed_clients: }
}
