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
    true    => $::opencontrail_ci::params::hosts['puppetdb'],
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

  # FIXME: Replace with package { 'eyaml': provider => 'puppetserver_gem' }
  # after we upgrade to 4.x and can install module.
  exec { 'puppetserver-eyaml':
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    command => 'puppetserver gem install --no-rdoc --no-ri hiera-eyaml',
    unless  => 'puppetserver gem list | grep -q "^hiera-eyaml"',
    notify  => Service['puppetserver'],
  }

  file { '/var/lib/puppet/.ssh/':
    ensure  => directory,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0700',
    require => User['puppet'],
  }

  ssh_authorized_key { 'gerrit@review2.opencontrail.org':
    ensure  => present,
    user    => 'puppet',
    type    => 'ssh-rsa',
    key     => hiera('gerrit_ssh_rsa_pubkey'),
    require => File['/var/lib/puppet/.ssh/'],
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
    hierarchy     => [
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
