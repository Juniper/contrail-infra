class opencontrail_ci::params {
  $hosts               = hiera('opencontrail_ci::hosts')
  $project_config_repo = hiera('opencontrail_ci::project_config_repo')
}
