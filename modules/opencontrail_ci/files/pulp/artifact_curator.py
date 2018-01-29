#! /usr/bin/env python
from __future__ import print_function
import json
import requests
from docker import Client

"""
This script will remove all registry containers created by buildsets that have already finished
Registry container format: registry_{change}_{patchset}_{first 10 chars of buildset sha}
TODO: remove pulp rpm repos
"""

dry_run = False

registries = []
running_buildsets = []

# Get the list of running containers first to prevent race condition
cli = Client()
containers = cli.containers()
for container in containers:
    #print(container['Names'])
    assert len(container['Names']) > 0
    name = container['Names'][0]
    if name.startswith('/registry_'):
        _, change, patchset, buildset = name.split('_')
        registries.append({'change': change, 'patchset': patchset, 'buildset': buildset})#, 'name': name})

# Get the list of running builds(ets) from Zuul status
req = requests.get('http://zuulv3.opencontrail.org/status.json')
build_data = req.json()
#print(json.dumps(build_data, indent=4))
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
print()
for cont in registries:
    if cont in running_buildsets:
        print('Not removing', cont)
    else:
        print('Removing,', cont)
        to_delete.append(cont)
for cont in to_delete:
    name = 'registry_{change}_{patchset}_{buildset}'.format(**cont)
    print(name)
    if not dry_run:
        # TODO handle already removed containers
        c = cli.remove_container(name, v=True, force=True)
        print(c)
