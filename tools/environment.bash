#!/bin/bash
#
# environment-specific variables for the bootstrap process.
declare -A HOSTS
HOSTS[puppetdb]=puppetdb2.opencontrail.org
HOSTS[puppetmaster]=ci-puppetmaster2.opencontrail.org
ENVIRONMENT=development
