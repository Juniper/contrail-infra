import yaml
import os
import sys

PREFIX = "INJECT_"

if len(sys.argv) < 3:
    print "Please specify input file and image name as parameters:"
    print os.path.basename(__file__), "<input_file> <image_name>"
    exit(1)
else:
    template = sys.argv[1]
    image_name = sys.argv[2]

# Get variables to inject from environment - prefix them with PREFIX 
injectable_vars = [entry for entry in os.environ.items() if
                   entry[0].startswith(PREFIX)]

with open(template) as tmpl:
    nodepool_yaml = yaml.load(tmpl.read())

disk_images = nodepool_yaml['diskimages']

for i, image in enumerate(disk_images):
    if image['name'] != image_name:
        continue

    for entry in injectable_vars:
        dib_key = entry[0][len(PREFIX):]  # Remove PREFIX
        dib_val = entry[1]
        image['env-vars'][dib_key] = dib_val

    disk_images[i] = image

nodepool_yaml['diskimages'] = disk_images

print yaml.dump(nodepool_yaml, default_flow_style=False)
