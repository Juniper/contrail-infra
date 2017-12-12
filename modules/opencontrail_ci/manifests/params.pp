class opencontrail_ci::params {
  $cloud_credentials        = hiera('opencontrail_ci::cloud_credentials', {})
  $hosts                    = hiera('opencontrail_ci::hosts')
  $project_config_repo      = hiera('opencontrail_ci::project_config_repo')
  $vim_package              = $::osfamily ? {
    'Debian' => 'vim-nox',
    'RedHat' => 'vim-enhanced',
    default => 'vim',
  }
  $dnsutils_package         = $::osfamily ? {
    'Debian' => 'dnsutils',
    'RedHat' => 'bind-utils',
    default => 'dnsutils',
  }
  $common_packages          = [
    'curl', 'atop', 'tcpdump', 'unzip', 'strace',
    'sysstat', 'iotop', $vim_package, $dnsutils_package
  ]
}
