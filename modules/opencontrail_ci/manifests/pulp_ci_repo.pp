class opencontrail_ci::pulp_ci_repo inherits opencontrail_ci::params {

    firewall { '100 accept all tcp - docker registries per-review':
        proto  => 'tcp',
        action => 'accept',
    }

    pulp_rpmrepo { 'opencontrail-tpc':
        ensure        => present,
        display_name  => 'opencontrail-tpc',
        description   => 'Third party packages required for OpenContrail build',
        relative_url  => 'opencontrail-tpc',
        serve_http    => true,
        serve_https   => true,
        checksum_type => 'sha256',
        require       => [ Service['pulp_resource_manager', 'httpd'], Class['pulp::admin'] ],
    }

    pulp_rpmrepo { 'centos74':
        ensure        => present,
        skip          => 'distribution',
        display_name  => 'centos74',
        description   => 'englab centos74 mirror',
        relative_url  => 'centos74',
        serve_http    => true,
        serve_https   => true,
        checksum_type => 'sha256',
        feed          => 'http://mirrors.mit.edu/centos/7/os/x86_64/',
    }

    pulp_rpmrepo { 'centos74-updates':
        ensure        => present,
        display_name  => 'centos74-updates',
        description   => 'englab centos74-updates mirror',
        relative_url  => 'centos74-updates',
        serve_http    => true,
        serve_https   => true,
        checksum_type => 'sha256',
        feed          => 'http://mirrors.mit.edu/centos/7/updates/x86_64/',
    }

    pulp_rpmrepo { 'centos74-extras':
        ensure        => present,
        display_name  => 'centos74-extras',
        description   => 'englab centos74-extras mirror',
        relative_url  => 'centos74-extras',
        serve_http    => true,
        serve_https   => true,
        checksum_type => 'sha256',
        feed          => 'http://mirrors.mit.edu/centos/7/extras/x86_64/',
    }

    pulp_rpmrepo { 'centos74-epel':
        ensure        => present,
        display_name  => 'centos74-epel',
        description   => 'englab centos74-epel mirror',
        relative_url  => 'centos74-epel',
        serve_http    => true,
        serve_https   => true,
        checksum_type => 'sha256',
        feed          => 'http://mirrors.mit.edu/epel/7/x86_64/',
    }
    
    file { '/opt/opencontrail_ci/repo_sync.sh':
        ensure  => file,
        source  => 'puppet:///modules/opencontrail_ci/pulp/repo_sync.sh',
        mode    => '0700',
        owner   => 'root',
        require => [
            File['/opt/opencontrail_ci']
        ],
    }

    cron { 'sync_repos':
        command => '/opt/opencontrail_ci/repo_sync.sh'
        user    => 'root',
        hour    => '1',
        require => [
            File['/opt/opencontrail_ci/repo_sync.sh']
        ],
    }
}
