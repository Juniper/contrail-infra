class opencontrail_ci::acid (
  $config_template = undef,
  $path = '/opt/acid',
  $homedir = '/var/lib/acid',
  $user = 'acid',
  $group = $user,
  $bind_address = 'localhost:8000',
  $git_origin = 'http://github.com/codilime/acid',
  $git_revision = 'master',
  $acid_db_host = 'localhost',
  $acid_db_port = '3306',
  $acid_db_name = 'acid',
  $acid_db_user = 'acid',
  $acid_db_pass = 'acid',
  $acid_zuul_url = 'http://zuul.acid/',
  $acid_log_url = 'http://logs.acid/',
  ### used for managing zuul - start/stop build
  $acid_ssh_public_key = undef,
  $acid_ssh_private_key = undef,
  $acid_manager_host = 'localhost',
  $acid_manager_tenant = 'acid',
  $acid_manager_user = 'acid',
  $acid_manager_project = 'acid',

) inherits opencontrail_ci::params {

  class { '::python':
      version         => 'system',
      pip             => 'present',
      dev             => 'present',
      virtualenv      => 'present',
      gunicorn        => 'present',
      manage_gunicorn => true,
  }

  accounts::user { $user:
    ensure        => present,
    comment       => 'ACID CI Dashboard',
    group         => $group,
    home          => $homedir,
    purge_sshkeys => true,
    sshkeys       => $acid_ssh_public_key,
  }

  vcsrepo { $path:
    ensure   => latest,
    provider => 'git',
    revision => $git_revision,
    source   => $git_origin,
    notify   => [
        Python::Requirements["${path}/requirements.txt"],
        Python::Gunicorn['acid']
        ],
  }

  python::pyvenv { $path:
      ensure  => present,
      version => '3.6',
      owner   => $user,
      group   => $group,
      require => Vcsrepo[$path],
  }

  python::requirements { "${path}/requirements.txt":
      virtualenv => $path,
      owner      => $user,
      group      => $group,
      require    => Vcsrepo[$path],
  }

  file { "${homedir}/.ssh":
      ensure => directory,
      owner  => $user,
      group  => $group,
  }

  file { "${path}/settings.yml":
      ensure  => present,
      content => template('acid/settings.yml.erb'),
      owner   => $user,
      group   => $group,
      mode    => '0644',
      require => Vcsrepo[$path],
  }

  file { "${homedir}/.ssh/id_rsa":
      content => $acid_ssh_private_key,
      owner   => $user,
      group   => $group,
      mode    => '0600',
      require => File["${path}/.ssh"],
  }

  file { "${homedir}/.ssh/zuul_host_key.pub":
      content => $acid_manager_zuul_host_key,
      owner   => $user,
      group   => $group,
      mode    => '0644',
      require => File["${path}/.ssh"],
  }

  python::gunicorn { 'acid':
      ensure     => latest,
      virtualenv => $path,
      dir        => "${path}/acid",
      bind       => $bind_address,
      require    => [
          Vcsrepo[$path],
          File["${path}/settings.yml"],
          Python::Requirements["${path}/requirements.txt"]
          ],
  }
}
