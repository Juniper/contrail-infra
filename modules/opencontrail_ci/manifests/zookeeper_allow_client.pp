define opencontrail_ci::zookeeper_allow_client {
  firewall { "100 allow zookeeper connection for ${title}":
    proto  => 'tcp',
    dport  => hiera('zookeeper::client_port', 2181),
    source => $title,
    action => 'accept',
  }
}
