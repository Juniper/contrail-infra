class opencontrail_ci::server inherits opencontrail_ci::params {
  include ::opencontrail_ci::users

  class { '::firewall': }
  resources { 'firewall':
      purge => true,
  }

  class { '::puppet':
    server                    => false,
    puppetmaster              => $::opencontrail_ci::params::hosts['puppetmaster'],
    agent_additional_settings => {
      stringify_facts => false,
    }
  }

  class { '::sudo': }

  # Puppet style guide states that arrows should be added on the
  # left side of the operand, and in most cases that indeed is
  # easier to read, but not in the following case, where we have
  # a list of multi-line resources with strict ordering.
  # lint:ignore:arrow_on_right_operand_line
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
    dport  => 22,
    proto  => 'tcp',
    action => 'accept',
  }->
  firewall { '999 drop all other requests':
    action => 'drop',
  }
  # lint:endignore

  package { 'curl':
    ensure => present,
  }

  sudo::conf { 'sudo':
    priority => 10,
    content  => '%sudo ALL=(ALL) NOPASSWD: ALL',
  }
}
