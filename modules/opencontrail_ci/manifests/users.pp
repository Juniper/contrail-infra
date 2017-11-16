class opencontrail_ci::users(
  $accounts
) {
  # ensure that the ubuntu user is locked.
  # XXX: we really should just delete the user, but that wreaks havoc with assumptions made
  # by the bootstrap process.
  accounts::user { 'ubuntu':
    locked => true,
  }

  create_resources('accounts::user', $accounts)
}
