class opencontrail_ci::stats {

  firewall { '003 accept inbound mysql':
    source => '148.251.110.16/28',
    proto  => 'tcp',
    dport  => [3306, 7999],
    action => 'accept'
  }

  firewall { '003 accept inbound mysql - Juniper India':
    source => '116.197.184.0/23',
    proto  => 'tcp',
    dport  => 3306,
    action => 'accept'
  }

  firewall { '003 accept inbound mysql - nodepool nodes':
    source => '66.129.224.0/19',
    proto  => 'tcp',
    dport  => [3306, 7999, 8080],
    action => 'accept'
  }

  firewall { '003 accept inbound mysql - stats-dev (grafana)':
    source => '148.251.5.91/32',
    proto  => 'tcp',
    dport  => 3306,
    action => 'accept'
  }

}
