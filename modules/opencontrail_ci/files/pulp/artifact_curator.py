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
from docker.errors import NotFound, APIError

"""
This script will remove all registry containers created by buildsets that have already finished
Registry container format: registry_{change}_{patchset}_{first 10 chars of buildset sha}
TODO: remove pulp rpm repos
"""

logger = logging.getLogger('artifact_curator')
review_re = re.compile(r"""^\d+-\d+$""") # <changeset>-<patchset>
version_re = r"""\d+(\.\d+)+|master"""

# Regexp to match only review repositories (<changeset>-<patchset>-<distro>-<openstack_version>):
#   - 37999-1-centos
#   - 38123-12-rhel-ocata
#   - 38123-2-rhel-queens
review_repo_regex = re.compile(r"""^\d+-\d+-(centos|rhel)(-[a-z]+|$)""")

# Regexp to match only nightly repositories:
#   - master-1-centos
#   - master-2-rhel-ocata
#   - master-3-rhel-queens
#   - 5.0-14-centos
#   - 5.0-12-rhel-ocata
#   - 5.0-13-rhel-queens
nightly_repo_regex = re.compile(r"""^(""" + version_re + r""")-\d+-(centos|rhel)(-[a-z]+|$)""")
nightly_registry_regex = re.compile(r"""^registry_(""" + version_re + r""")_\d+_[a-f0-9]+$""")
version_re = re.compile(version_re)


def get_running_containers():
    """Get a list of running per-review docker registry containers

    Query Docker API for a list of containers, filtering by name that
    starts with "/registry_" - that gives us a list of all containers
    runnning docker registry for reviews.
    """
    # Get the list of running containers first to prevent race condition
    cli = Client()
    containers = cli.containers(all=True)
    registries = []
    for container in containers:
        logger.info(str(container['Names']))
        created = datetime.datetime.fromtimestamp(container['Created'])
        assert len(container['Names']) > 0
        name = container['Names'][0]
        if name.startswith('/registry_'):
            _, change, patchset, buildset = name.split('_')
            registries.append({'change': change, 'patchset': patchset, 'buildset': buildset, 'timestamp': created, 'name': name[1:]})
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
                    if not subhead['live']: # this is a dependent change, don't treat it as running
                        continue
                    buildset_id = subhead['zuul_ref'][1:] # zuul_ref == "Z" + <buildset id>
                    buildset_id = buildset_id[:10]
                    if subhead['id']:
                        change, patchset = subhead['id'].split(',')
                    else:
                        change, patchset = None, None
                    running_buildsets.append({
                        'change': change,
                        'patchset': patchset,
                        'buildset': buildset_id})
    return running_buildsets


def get_pulp_repositories():
    """Return a list of review-related Pulp repositories

    Returns a list of Pulp repositories, filtering all but
    per-review repositories, leaving out "static" ones.
    """

    repos = []

    pulp_repo_list = \
        subprocess.check_output(["/bin/pulp-admin", "rpm", "repo", "list", "--details"]).split("\n")
    # due to multiple "Last Updated" lines in output we need to make sure that we emit each repo only once
    # use this flag for it
    record_started = False
    for line in pulp_repo_list:
        #logger.info('AAA: ' + line)
        if line.startswith("Id:"):
            repo = line.split()[1]
            record_started = True
        if line.startswith("  Last Updated:") and record_started:
            timestamp = line.split()[-1]
            # Example pulp output time format: 2018-05-01T06:19:25Z
            timestamp = datetime.datetime.strptime(timestamp, "%Y-%m-%dT%H:%M:%SZ")
            # append repo to the list only if it is nightlty or per-review: ignore static ones
            if re.match(review_repo_regex, repo) or re.match(nightly_repo_regex, repo):
                repos.append({"name": repo, "timestamp": timestamp})
            record_started = False

    # XXX(kklimonda): development-only, verify that static repositories are not returned
    def assert_not_static_repo(repos):
        static_repos = [
            "centos74", "centos74-epel", "centos74-extras",
            "centos74-updates", "opencontrail-tpc", "opencontrail-tpc-R5.0", "opencontrail-tpc-master"
        ]
        for repo in repos:
            assert repo['name'] not in static_repos
    assert_not_static_repo(repos)
    logger.info("Found %s candidate repos for deletion", len(repos))
    return repos


def check_call(command, dry_run=True):
    """Wrapper for subprocess.check_call with dry_run support"""
    if dry_run:
        logger.debug("DRY_RUN: %s", " ".join(command))
    else:
        subprocess.check_call(command)


def match_subdict(d1, d2):
    """Returns true iff d2 contains all the k/v pairs from the d1 dict"""
    d2_view = d2.viewitems()
    return all(d1_item in d2_view for d1_item in d1.viewitems())


def unpack_repo_name(repo_name):
    try:
        change, patchset, distro, openstack_version = repo_name.split('-')
    except ValueError:
        change, patchset, distro, openstack_version = repo_name.split('-') + [None]
    return change, patchset, distro, openstack_version


def delete_pulp_repos(repo_list, active_buildsets, nightly_retention_days, dry_run=True):
    """Delete Pulp repositories that are not part of the running buildsets"""
    logger.info("STAGE: Deleting Pulp RPM repositories")
    cleanup_list = []
    threshold_date = datetime.datetime.now()-datetime.timedelta(days=nightly_retention_days)
    for repo in repo_list:
        if re.match(review_repo_regex, repo['name']):
            change, patchset, distro, _ = unpack_repo_name(repo['name'])
            if any(match_subdict({'change': change, 'patchset': patchset}, buildset) for buildset in active_buildsets):
                logger.info("Keeping repository %s: part of active buildset", repo)
            else:
                logger.info("Removing repository %s: matching buildset missing", repo)
                cleanup_list.append(repo['name'])
        elif re.match(nightly_repo_regex, repo['name']):
            if repo['timestamp'] < threshold_date:
                logger.info("Removing nightly repository %s: too old", repo)
                cleanup_list.append(repo['name'])
            else:
                logger.info("Keeping nightly repository %s: too fresh", repo)
        else:
            logger.info("Keeping repository %s: didn't match any deletion criteria", repo)
    for repo in cleanup_list:
        delete_repo_command = ["/bin/pulp-admin", "rpm", "repo", "delete", "--repo-id", repo]
        check_call(delete_repo_command, dry_run)
    delete_orphans_command = ["/bin/pulp-admin", "orphan", "remove", "--type=rpm"]
    check_call(delete_orphans_command, dry_run)


def delete_containers(container_list, active_buildsets, nightly_retention_days, dry_run=True):
    """Delete all containers that are not part of active buildsets"""
    logger.info("STAGE: Deleting Containers")
    to_delete = []
    active_buildset_ids = [x['buildset'] for x in active_buildsets]
    threshold_date = datetime.datetime.now() - datetime.timedelta(days=nightly_retention_days)
    for cont in container_list:
        if cont['buildset'] in active_buildset_ids:
            logger.info('Keeping %s: part of active buildset', cont)
        elif re.match(nightly_registry_regex, cont['name']):
            if cont["timestamp"] < threshold_date:
                logger.info('Removing nightly container %s: too old', cont)
                to_delete.append(cont)
            else:
                logger.info('Keeping nightly container %s: too fresh', cont)
        else:
            logger.info('Removing %s: matching buildset missing', cont)
            to_delete.append(cont)

    logger.info('Will remove %s containers', len(to_delete))
    logger.info('Will not remove %s containers', len(container_list) - len(to_delete))

    cli = Client()
    for cont in to_delete:
        name = 'registry_{change}_{patchset}_{buildset}'.format(**cont)
        if dry_run:
            logger.debug("DRY_RUN: Removing %s", name)
        else:
            try:
                c = cli.remove_container(name, v=True, force=True)
            except NotFound as nf:
                logger.error('Container %s not found', name)
                logger.error(str(nf))
            except APIError as ae:
                logger.error('Docker API returned an error during removal of %s container', name)
                logger.error(str(ae))


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
    parser.add_argument("--nightly-retention-days", type=int, help="Set the number of days nightly repos and registries should be kept", required=True)
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

    delete_containers(container_list, active_buildsets, args.nightly_retention_days, dry_run=args.dry_run)
    delete_pulp_repos(pulp_repo_list, active_buildsets, args.nightly_retention_days, dry_run=args.dry_run)

if __name__ == "__main__":
    main()
