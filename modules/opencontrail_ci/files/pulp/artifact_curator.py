#!/usr/bin/env python
from __future__ import print_function


import argparse
import datetime
import json
import logging
import re
import requests
import subprocess
import sys

from docker import Client
from docker.errors import NotFound

"""
This script will remove all registry containers created by buildsets that have already finished
Registry container format: registry_{change}_{patchset}_{first 10 chars of buildset sha}
TODO: remove pulp rpm repos
"""

logger = logging.getLogger('artifact_curator')

def get_running_containers():
    """Get a list of running per-review docker registry containers

    Query Docker API for a list of containers, filtering by name that
    starts with "/registry_" - that gives us a list of all containers
    runnning docker registry for reviews.
    """
    # Get the list of running containers first to prevent race condition
    cli = Client()
    containers = cli.containers()
    registries = []
    for container in containers:
        logger.info(str(container['Names']))
        assert len(container['Names']) > 0
        name = container['Names'][0]
        if name.startswith('/registry_'):
            _, change, patchset, buildset = name.split('_')
            registries.append({'change': change, 'patchset': patchset, 'buildset': buildset})#, 'name': name})
    return registries


def get_active_buildsets():
    """Get the list of running builds(ets) from Zuul's status.json"""
    req = requests.get('http://zuulv3.opencontrail.org/status.json')
    build_data = req.json()
    running_buildsets = []
    for pipeline in build_data['pipelines']:
        for ch_queue in pipeline['change_queues']:
            for head in ch_queue['heads']:
                for subhead in head:
                    buildset_id = subhead['zuul_ref'][1:] # zuul_ref == "Z" + <buildset id>
                    buildset_id = buildset_id[:10]
                    if subhead['id']:
                        change, patchset = subhead['id'].split(',')
                        running_buildsets.append({'change': change, 'patchset': patchset, 'buildset': buildset_id})
    return running_buildsets


def get_pulp_repositories():
    """Return a list of review-related Pulp repositories

    Returns a list of Pulp repositories, filtering all but
    per-review repositories, leaving out "static" ones.
    """

    repos = []

    # Regexp to match only review repositories:
    #   - 37999-1
    #   - 38123-12
    #   - 5.0-20180202121314
    #   - 5.1-20180202121314
    #   - master-20180202121314
    #
    # This wont match any of the static repositories, e.g.
    # centos74, opencontrail-tpc, centos74-updates
    review_repo_re = r"""((\d+.)+\d+|master)-\d+"""

    pulp_repo_list = \
        subprocess.check_output(["/bin/pulp-admin", "rpm", "repo", "list", "--fields", "id"]).split("\n")
    for line in pulp_repo_list:
        if not line.startswith("Id:"):
            continue
        repo = line.split(" ")[1]
        if re.match(review_repo_re, repo):
            repos.append(repo)

    # XXX(kklimonda): development-only, verify that static repositories are not returned
    def assert_not_static_repo(repos):
        static_repos = [
            "centos74", "centos74-epel", "centos74-extras",
            "centos74-updates", "opencontrail-tpc", "repo1", "repo2"
        ]
        for repo in repos:
            assert repo not in static_repos

    assert_not_static_repo(repos)

    logger.info("Found %s candidate repos for deletion", len(repos))
    return repos


def delete_pulp_repos(repo_list, active_buildsets, dry_run=False):
    """Delete Pulp repositories that are not part of the running buildsets"""
    logger.info("STAGE: Deleting Pulp RPM repositories")
    active_changesets = [set['change'] + "-" + set['patchset'] for set in active_buildsets]
    cleanup_list = []
    review_re = r"""\d+-\d{1,3}"""
    for repo in repo_list:
        if repo in active_changesets:
            logger.info("Repository %s part of active buildset - skipping", repo)
            continue

        if re.match(review_re, repo):
            logger.info("Repository %s scheduled for deletion -- matching buildset missing", repo)
            cleanup_list.append(repo)
            continue

        # Repository is not part of an active buildset, but it can be used
        # by periodic jobs. Try parsing the repo name as version-timestamp,
        # and append repositories older than 24 hours to the cleanup list.
        try:
            _, timestamp = repo.split("-")
        except ValueError:
            logger.warning("Repository %s cannot be parsed: not version-timestamp format", repo)
            continue

        repository_date = datetime.datetime.strptime(timestamp, "%Y%m%d%H%M%S")
        now = datetime.datetime.now()
        logger.debug("repo date: %s, now: %s, delta: %s", repository_date, now, now-repository_date)
        if  datetime.datetime.now() - repository_date > datetime.timedelta(hours=24):
            logger.info("Repository %s scheduled for deletion -- older than 24 hours", repo)
        cleanup_list.append(repo)

    for repo in cleanup_list:
        command = ["/bin/pulp-admin", "rpm", "repo", "delete", "--repo-id", repo]
        if dry_run:
            logger.debug("DRY_RUN: %s", " ".join(command))
        else:
            subprocess.check_call(command)


def delete_containers(container_list, active_buildsets, dry_run=False):
    """Delete all containers that are not part of active buildsets"""
    logger.info("STAGE: Deleting Containers")
    to_delete = []
    for cont in container_list:
        if cont in active_buildsets:
            logger.info('Will not remove ' + str(cont))
        else:
            logger.info('Will remove ' + str(cont))
            to_delete.append(cont)

    logger.info('Will remove {} containers'.format(len(to_delete)))
    logger.info('Will not remove {} containers'.format(len(container_list) - len(to_delete)))

    cli = Client()
    for cont in to_delete:
        name = 'registry_{change}_{patchset}_{buildset}'.format(**cont)
        if dry_run:
            logger.debug("DRY_RUN: Removing %s", name)
        else:
            try:
                #c = cli.remove_container(name, v=True, force=True)
                logger.debug("WTF?")
            except NotFound as nf:
                logger.error('Container {} not found'.format(name))
                logger.error(str(nf))


def set_logging(args):
    log_filename = '/var/log/artifact_curator.log'

    logger.setLevel(logging.DEBUG)

    fh = logging.FileHandler(log_filename)
    fh.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    fh.setFormatter(formatter)

    log_level = logging.INFO
    if args.debug:
        log_level = logging.DEBUG

    console = logging.StreamHandler()
    console.setLevel(log_level)
    console.setFormatter(formatter)

    logger.addHandler(console)
    if log_level is not logging.DEBUG:
        logger.addHandler(fh)


def main():
    parser = argparse.ArgumentParser(description="Contrail Artifact Curator")
    parser.add_argument("--debug", action="store_true", help="Output debug messages")
    parser.add_argument("--dry-run", action="store_true", help="Don't delete anything")
    parser.add_argument("--yes", action="store_true", help="Don't ask any questions - just delete")
    args = parser.parse_args()

    set_logging(args)

    args = parser.parse_args()

    container_list = get_running_containers()
    pulp_repo_list = get_pulp_repositories()
    active_buildsets = get_active_buildsets()

    if not args.dry_run and not args.yes:
        print("")
        print(r"""\/\/\/\/WARNING\/\/\/\/""")
        print("We are about to delete things. Proceed?")
        yes_no = raw_input(r"""(y/N): """)
        if yes_no not in ["Y", "y"]:
            print("Cancelled by user. Exiting.")
            sys.exit(0)

    delete_containers(container_list, active_buildsets, dry_run=args.dry_run)
    delete_pulp_repos(pulp_repo_list, active_buildsets, dry_run=args.dry_run)

if __name__ == "__main__":
    main()

