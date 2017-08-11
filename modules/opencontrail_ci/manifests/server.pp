class opencontrail_ci::server inherits opencontrail_ci::params {
  include ::opencontrail_ci::users

  class { '::puppet':
    server                    => false,
    puppetmaster              => $hosts['puppetmaster'],
    agent_additional_settings => {
      stringify_facts => false,
    }
  }

  package { 'curl':
    ensure => present,
  }

  class { '::firewall': }
  resources { 'firewall':
      purge => true,
  }

  firewall { '000 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
  }->
  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '003 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }->
  firewall { '003 accept inbound ssh':
    dport    => 22,
    proto    => 'tcp',
    action   => 'accept',
  }->
  firewall { '999 drop all other requests':
    action => 'drop',
  }
}
