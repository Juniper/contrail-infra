#!/usr/bin/env python
import logging
import json
import requests
from docker import Client
from docker.errors import NotFound

"""
This script will remove all registry containers created by buildsets that have already finished
Registry container format: registry_{change}_{patchset}_{first 10 chars of buildset sha}
TODO: remove pulp rpm repos
"""

log_filename = '/var/log/artifact_curator.log'
logger = logging.getLogger('artifact_curator')
logger.setLevel(logging.INFO)
fh = logging.FileHandler(log_filename)
fh.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
fh.setFormatter(formatter)
logger.addHandler(fh)

dry_run = True
registries = []
running_buildsets = []

logger.info('Started artifact_curator, dry run: ' + str(dry_run))

# Get the list of running containers first to prevent race condition
cli = Client()
containers = cli.containers()
for container in containers:
    logger.info(str(container['Names']))
    assert len(container['Names']) > 0
    name = container['Names'][0]
    if name.startswith('/registry_'):
        _, change, patchset, buildset = name.split('_')
        registries.append({'change': change, 'patchset': patchset, 'buildset': buildset})#, 'name': name})

# Get the list of running builds(ets) from Zuul status
req = requests.get('http://zuulv3.opencontrail.org/status.json')
build_data = req.json()
for pipeline in build_data['pipelines']:
    for ch_queue in pipeline['change_queues']:
        for head in ch_queue['heads']:
            for subhead in head:
                buildset_id = subhead['zuul_ref'][1:] # zuul_ref == "Z" + <buildset id>
                buildset_id = buildset_id[:10]
                if subhead['id']:
                    change, patchset = subhead['id'].split(',')
                    running_buildsets.append({'change': change, 'patchset': patchset, 'buildset': buildset_id})

# Delete all registries created by non-running buildsets
to_delete = []
for cont in registries:
    if cont in running_buildsets:
        logger.info('Will not remove ' + str(cont))
    else:
        logger.info('Will remove ' + str(cont))
        to_delete.append(cont)

logger.info('Will remove {} containers'.format(len(to_delete)))
logger.info('Will not remove {} containers'.format(len(registries) - len(to_delete)))

for cont in to_delete:
    name = 'registry_{change}_{patchset}_{buildset}'.format(**cont)
    logger.info('Removing ' + name)
    if not dry_run:
        try:
            c = cli.remove_container(name, v=True, force=True)
        except NotFound as nf:
            logger.error('Container {} not found'.format(name))
            logger.error(str(nf))
