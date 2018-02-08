class opencontrail_ci::collectd {

  $graphite_host = hiera('opencontrail_ci::graphite_host')
  $graphite_port = hiera('opencontrail_ci::graphite_port')

  case $::osfamily {
    'Debian': {
      $install_options = ['--no-install-recommends']
    }
    default: {
      $install_options = undef
    }
  }

  class { '::collectd':
    purge                   => true,
    recurse                 => true,
    purge_config            => true,
    minimum_version         => '5.5',
    fqdnlookup              => false,
    package_install_options => $install_options,
  }

  class { '::collectd::plugin::syslog':
    log_level => 'info'
  }

  class { '::collectd::plugin::cpu': }
  class { '::collectd::plugin::uptime': }
  class { '::collectd::plugin::load': }
  class { '::collectd::plugin::memory': }
  class { '::collectd::plugin::processes': }
  class { '::collectd::plugin::swap': }
  class { '::collectd::plugin::users': }
  ::collectd::plugin { 'match_regex': }

  class { '::collectd::plugin::df':
    fstypes          => ['sysfs', 'proc', 'devtmpfs', 'devpts', 'tmpfs'],
    ignoreselected   => true,
    reportbydevice   => false,
    reportreserved   => true,
    reportinodes     => true,
    valuesabsolute   => true,
    valuespercentage => true,
  }

  class { '::collectd::plugin::disk':
    disks          => ['/^[vhs]d[a-z]'],
    ignoreselected => false,
  }

  class { '::collectd::plugin::aggregation':
    aggregators => {
      cpu => {
        plugin           => 'cpu',
        agg_type         => 'cpu',
        groupby          => ['Host', 'TypeInstance',],
        calculateaverage => true,
      },
    },
  }

  class { '::collectd::plugin::interface':
    interfaces     => ['lo', '/^veth.*/', '/^docker.*/'],
    ignoreselected => true
  }

  class { '::collectd::plugin::statsd':
    host            => '127.0.0.1',
    port            => 8125,
    timerpercentile => ['90'],
  }

  ::collectd::plugin::write_graphite::carbon { 'graphite-dev':
      graphitehost      => $graphite_host,
      graphiteport      => $graphite_port,
      graphiteprefix    => 'ci.',
      protocol          => 'tcp',
      escapecharacter   => '.',
      alwaysappendds    => false,
      storerates        => true,
      separateinstances => true,
      logsenderrors     => true
  }

class { '::collectd::plugin::chain':
    chainname     => 'PostCache',
    defaulttarget => 'write',
    rules         => [
      {
        'match'   => {
          'type'    => 'regex',
          'matches' => {
            'Plugin'         => '^cpu$',
            'PluginInstance' => '^[0-9]+$',
          },
        },
        'targets' => [
          {
            'type'       => 'write',
            'attributes' => {
              'Plugin' => 'aggregation',
            },
          },
          {
            'type' => 'stop',
          },
        ],
      },
    ],
  }

}
