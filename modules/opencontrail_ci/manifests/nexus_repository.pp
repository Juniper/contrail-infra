class opencontrail_ci::nexus_repository(
  $registry_ports = [5000],
) {
  include '::gnupg'

  gnupg_key { 'nexus3-yum-repo':
    ensure     => present,
    key_id     => 'a6f34cb3',
    user       => 'root',
    key_source => 'puppet:///modules/opencontrail_ci/nexus3_gpg.pub',
    key_type   => 'public',
  }

  yumrepo {'nexus3-yum-repo':
    baseurl  => 'https://download.opensuse.org/repositories/home:/tungsten-infra:/third-party-packages/CentOS_7/',
    descr    => 'Nexus3 subrepository (CentOS_7)',
    enabled  => true,
    gpgcheck => true,
    gpgkey   => 'https://download.opensuse.org/repositories/home:/tungsten-infra:/third-party-packages/CentOS_7/repodata/repomd.xml.key',
  }

  package {'nexus3':
    ensure  => '3.14.0.04-8.1',
    require => [
      Gnupg_key['nexus3-yum-repo'],
      Yumrepo['nexus3-yum-repo'],
    ]
  }

  service {'nexus3':
    ensure    => running,
    enable    => true,
    subscribe => Package['nexus3'],
  }

  # Setup reverse proxy
  include '::nginx'

  nginx::resource::server { $::fqdn:
      listen_port       => 80,
      proxy             => 'http://127.0.0.1:8081',
      server_cfg_append => {
        'client_max_body_size' => '1G',
      },
  }

  selboolean {'httpd_can_network_connect':
    persistent => true,
    value      => on,
  }

  firewall {'100 accept all HTTP(s)':
    proto  => tcp,
    dport  => [80, 443],
    action => accept,
  }

  firewall {'101 accept ports for nexus docker registries':
    proto  => tcp,
    dport  => $registry_ports,
    action => accept,
  }
}
