class opencontrail_ci::params {
  $hosts                    = hiera('opencontrail_ci::hosts')
  $project_config_repo      = hiera('opencontrail_ci::project_config_repo')
  $common_packages          = [
    'curl', 'atop', 'tcpdump', 'unzip', 'strace',
    'dnsutils', 'vim-nox', 'sysstat', 'iotop'
  ]
}
