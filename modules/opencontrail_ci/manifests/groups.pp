class opencontrail_ci::groups {
  # This group is not availble on CentOS systems by default
  group { 'sudo':
    ensure => present,
    system => true,
  }
}
