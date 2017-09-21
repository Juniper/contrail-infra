class opencontrail_ci::params {
  $hosts                    = hiera('opencontrail_ci::hosts')
  $nodepool_ssh_private_key = hiera('nodepool_ssh_private_key')
  $project_config_repo      = hiera('opencontrail_ci::project_config_repo')
  $common_packages          = [
    'curl', 'atop', 'tcpdump', 'unzip', 'strace',
    'dnsutils', 'vim-nox', 'sysstat', 'iotop'
  ]
}
