#!/bin/bash
set -e

. environment.bash

if [ $EUID -ne 0 -o -z "$SUDO_USER" ]; then
    echo "This script must executed with sudo from normal user"
    exit 1
fi

# Install ansible and bootstrap the control node.
# We'll create a temporary virtualenv for ansible, and
# then run bootstrap playbook that handles the rest
# of the process.

SCRIPT_DIR=$(dirname $(readlink -f $0))
PROJECT_DIR=$(readlink -f $SCRIPT_DIR/../)
MODULES_DIR=${PROJECT_DIR}/modules/

if [ ! -x /usr/bin/puppet ]; then
    bash ${SCRIPT_DIR}/install_puppet.sh
fi
# install gem and explicitly puppet_forge dependency (to fix conflicting
# dependencies)
if [ ! -x /usr/local/bin/r10k ]; then
    gem install --verbose --no-rdoc --no-ri puppet_forge -v '2.2.6'
    gem install --verbose --no-rdoc --no-ri r10k
fi

if [ ! -f $HOME/.ssh/id_rsa ]; then
    mkdir $HOME/.ssh/ > /dev/null 2>&1 || /bin/true
    ssh-keygen -b 2048 -t rsa -f $HOME/.ssh/id_rsa -q -N ""
    cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
fi

# bootstrap puppet modules into local modules/ directory
# XXX: run it as puppet so that potential /var/cache/r10k/, and
# cached modules have correct owner.
if [ ! -f /etc/r10k.yaml ]; then
    echo "cachedir: /var/cache/r10k/" > /etc/r10k.yaml
fi
if [ ! -d /var/cache/r10k/ ]; then
    mkdir /var/cache/r10k/
    chown puppet:puppet /var/cache/r10k/
fi
chown :puppet ${MODULES_DIR}
chmod g+w ${MODULES_DIR}
cd ${PROJECT_DIR}
if [ ! -d vendor ]; then
    mkdir vendor
fi
chown puppet vendor

sudo -u puppet r10k puppetfile install --verbose info \
  --moduledir ${MODULES_DIR} --puppetfile ${PROJECT_DIR}/Puppetfile

# initial puppet run to deploy puppet master, without puppetdb
# integration. Both server and puppetmaster classes are applied,
# to fullfill module dependencies.
puppet apply --hiera_config ${SCRIPT_DIR}/hiera.yaml \
  --modulepath ${PROJECT_DIR}/modules/:${PROJECT_DIR}/vendor \
  -e "class { '::opencontrail_ci::server': } -> class { 'opencontrail_ci::puppetmaster': puppetdb_enabled => false }"

# create /etc/ansible/hosts for bootstrap
cat > /etc/ansible/hosts <<-EOF
[puppet]
puppetdb ansible_host=${HOSTS[puppetdb]}
puppetmaster ansible_host=${HOSTS[puppetmaster]}
EOF
# install required ansible roles
ansible-galaxy install -r roles.yaml --force
# run ansible to finish the bootstrap process
rm -rf $HOME/.ansible/
sudo -u ${SUDO_USER} ANSIBLE_SSH_PIPELINING=True ansible-playbook ${PROJECT_DIR}/playbooks/bootstrap_puppet.yaml --user ubuntu --sudo --private-key $HOME/.ssh/id_rsa --extra-vars "puppet_environment=$ENVIRONMENT puppetdb_host=${HOSTS[puppetdb]} puppetmaster_host=${HOSTS[puppetmaster]} current_branch=$CURRENT_BRANCH"
