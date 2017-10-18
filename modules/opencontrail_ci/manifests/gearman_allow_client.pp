define opencontrail_ci::gearman_allow_client {
  firewall { "300 allow gearman connection for ${title}":
    proto  => 'tcp',
    dport  => hiera('zuul::gearman_listen_port', 4730),
    source => $title,
    action => 'accept',
  }
}
