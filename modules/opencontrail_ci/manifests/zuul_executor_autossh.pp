class opencontrail_ci::zuul_executor_autossh(
  $finger_port = 7900,
  $monitoring_port = 10000,
  $ssh_user = 'zuul-proxy',
  $ssh_key_path = '/var/lib/zuul/ssh/id_rsa',
  $zuul_host = undef,
) {

  package { 'autossh':
      ensure => installed,
  }

  file { '/etc/systemd/system/autossh-zuul.service':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    content => template('opencontrail_ci/autossh-zuul.service.erb'),
    notify => Service['autossh-zuul'],
  }

  service { 'autossh-zuul':
    ensure    => running,
    enable    => true,
    require => [ Package['autossh'], File['/etc/systemd/system/autossh-zuul.service'] ],
  }
}
