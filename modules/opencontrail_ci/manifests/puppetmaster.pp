class opencontrail_ci::puppetmaster(
  $puppetdb_enabled = true,
) inherits opencontrail_ci::params {

  # support bootstrapping by allowing puppetserver to run without
  # puppetdb until it's deployed.
  $reports = $puppetdb_enabled ? {
    true    => 'puppetdb,store',
    default => 'store',
  }
  $storeconfigs_backend = $puppetdb_enabled ? {
    true    => 'puppetdb',
    default => false,
  }
  $puppetdb_host = $puppetdb_enabled ? {
    true    => $hosts['puppetdb'],
    default => undef,
  }

  package { 'puppet_forge':
    ensure   => '2.2.6',
    provider => 'gem',
  }

  package { 'r10k':
    provider => 'gem',
    require  => Package['puppet_forge'],
  }

  file { "/var/lib/puppet/.ssh/":
    ensure  => directory,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0700',
    require => User['puppet'],
  }

  ssh_authorized_key { 'gerrit@review.opencontrail.org':
    ensure  => present,
    user    => 'puppet',
    type    => 'ssh-rsa',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC8xYbz7ohnFJuo8pvaRmzzRazLAPzGTcwcq848iKx6W9OZWjHMKJ40TiMM4RyeWvjGP68aEkLA6Pgdrxlf1e2rmiIH5il+znLEHslnpA3FjWbRMx5HiXn4ZKmVvFU8uGmXPeevMbHM+YJdxkMjAdf9uV8pA4EmUcsdyxK9oLZFDWsvJEeZXz6Andc+wpYCNh3FNoRO0+lIhuFdzXhf2a9mVqV3TmkgUW4KojH03kEGzudsZ+9ZZuKOe2TevHA58atabSiKQfg7T2q1EmNObpcEacxFiVsmT8DgbkHjN+AftsFulUKPA9kzfSYmfAX238Ib4aSKcvpONPi/RKzh5ee3',
    require => File["/var/lib/puppet/.ssh/"],
  }

  file { '/var/lib/r10k':
    ensure  => directory,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0750',
    require => User['puppet'],
  }

  class { '::puppet::server':
    implementation       => 'puppetserver',
    parser               => 'future',
    hiera_config         => '/etc/puppet/hiera.yaml',
    puppetserver_version => '1.2.0',
    foreman              => false,
    external_nodes       => '',
    reports              => $reports,
    puppetdb_host        => $puppetdb_host,
    storeconfigs_backend => $storeconfigs_backend,
    admin_api_whitelist  => [],
    git_repo             => true,
    environments         => [],
    post_hook_content    => 'opencontrail_ci/puppet/server/oc-post-receive.erb',
  }
  Class['::puppet::server'] -> Class['::puppet']

  class { '::hiera':
    hierarchy => [
      'fqdn/%{::clientcert}',
      'common',
    ],
    datadir       => '/etc/puppet/environments/%{::environment}/hiera/',
    eyaml         => true,
    eyaml_datadir => '/var/lib/puppet/hieradata/%{::environment}',
  }

  class { '::ansible':
    ansible_version => '2.2.2.0',
    require         => Package['curl'],
  }

  firewall { '100 accept tcp 8140 from everywhere':
    proto  => 'tcp',
    dport  => '8140',
    action => 'accept',
  }
}
