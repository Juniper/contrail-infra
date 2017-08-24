:title: Contributing to the OpenContrail CI repository

.. _contributing_oc_ci:

Contributing to OpenContrail CI repository
==========================================

This document describes how to contribute to repositories managed by the
OpenContrail infrastructure team, including quick overview of the repository,
development setup for working with Puppet code, as well as review process.

Repository Layout
-----------------

Working with Puppet code
------------------------

This repository provides an "entry point" for the Puppet infrastructure, that
is both the main manifest used for assigning profiles[1]_ to nodes, as well
as the opencontrail_ci module that defines those roles.

.. [1] While we follow the practice of minimizing the amount of code put into
   the main manifest, this repository does not implement "Roles and Profiles"
   pattern directly, as described by Puppetlabs et al. - in our workflow,
   the role is not used at all, and profile is "squashed" into the main
   manifest.

Preparing local development environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A local development environment can be easily configured, so that all tools
needed to check syntax, lint code and manage modules is available when
needed.

A local Gemfile (and its companion, Gemfile.lock) list all the dependencies
that have to be installed, and is used by Bundler to create local
environments.

To use bundler, first a correct version of Ruby needs to be installed.
Puppet 3.x requires Ruby 1.8.7, 1.9.3, 2.0.x or 2.1.x - Gemfile specifies
2.1.10 as a required version, but any one of the releases mentioned can
be used, depending on which is available on the system. If no correct version
of Ruby is available, RVM_ can be used to install correct Ruby version[2]_,
and even creating a gemset to isolate dependencies from the main Ruby
installation.

RVM installation and operations is out of the scope of this document, but the
quick start guide written on the project main page works as advertised on
both macOS 10.12 and major Linux distribution.

.. [2] If RVM is used, we recommend installing latest 2.1 Ruby release,
   as this is used by the rest of the team for the development.
   At the same time, the version should not have any effect
   on the process, so this is not required.
.. _RVM: https://rvm.io

Hiera
~~~~~

Hiera is a key/value store used by puppet to abstract data from code. However,
due to the fact that YAML is not the easiest language to modify (or, in some
cases, even read) we limit Hiera usage to cases where it has most impact,
like handling sensitive information (using hiera-eyaml backend) and storing
large blobs of text (like SSH keys[3]_). In particular, mixing hiera data
with variables defined in the manifest should be avoided, and used mostly
when needed, or to increase readability of the code.

.. [3] Observant readers will notice that public SSH keys for OpenContrail
   infrastructure team don't follow that rule, and are instead kept in the
   opencontrail_ci::users manifest directly. That's done to avoid splitting
   user parameters between two places.

Sensitive Data
~~~~~~~~~~~~~~

Some of the puppet code depends on the sensitive data (private SSH
& SSL keys, passwords, API keys etc.) and care must be taken to ensure that
those are not disclosed to the public. For that reason, Hiera repository
is split into two, and puppet master is configured to traverse both
hierarchies in search of the data. Additionally, this data is encrypted
with keys stored only on puppet master nodes (and in encrypted backups).

This is achieved by utilizing Hiera's backend functionality, using EYAML
backend for encryption. Repository for this is private and made available
only to the core OpenContrail infrastructure team. The modification of the
repository should also be done only by accessing it directly on the puppet
master node, which can again be done only by authorized users.

Third party modules
~~~~~~~~~~~~~~~~~~~

Third-party modules are not stored in contrail-infra repository, instead each
module lives on its own, either in upstream or, when local changes are
required, in a separate repository in Juniper GitHub project. Those modules
are then installed (both for local development, and for deployments) using
r10k, to the vendor/ directory[4]_.

A list of all modules (and their dependencies[5]_) is defined in Puppetfile,
with each module being listed with its version (and location when module
is not available from Puppet Forge).

Puppetfile can be used during development, to install all third-party modules
for reference and to aid code completion in IDEs. This can be done by running
r10k in the "puppetfile" mode:

.. code-block:: shell-session

   $ r10k puppetfile --verbose info install
   r10k puppetfile --verbose info install
   INFO     -> Updating module vendor/opencontrail_ci
   INFO     -> Updating module /home/user/contrail-infra/vendor/ansible
   INFO     -> Updating module /home/user/contrail-infra/vendor/httpd
   INFO     -> Updating module /home/user/contrail-infra/vendor/logrotate
   INFO     -> Updating module /home/user/contrail-infra/vendor/pip
   INFO     -> Updating module /home/user/contrail-infra/vendor/project_config
   INFO     -> Updating module /home/user/contrail-infra/vendor/vcsrepo
   INFO     -> Updating module /home/user/contrail-infra/vendor/zuul
   INFO     -> Updating module /home/user/contrail-infra/vendor/extlib
   INFO     -> Updating module /home/user/contrail-infra/vendor/hiera
   INFO     -> Updating module /home/user/contrail-infra/vendor/firewall
   INFO     -> Updating module /home/user/contrail-infra/vendor/inifile
   INFO     -> Updating module /home/user/contrail-infra/vendor/postgresql
   INFO     -> Updating module /home/user/contrail-infra/vendor/puppetdb
   INFO     -> Updating module /home/user/contrail-infra/vendor/accounts
   INFO     -> Updating module /home/user/contrail-infra/vendor/apache
   INFO     -> Updating module /home/user/contrail-infra/vendor/apt
   INFO     -> Updating module /home/user/contrail-infra/vendor/concat
   INFO     -> Updating module /home/user/contrail-infra/vendor/stdlib
   INFO     -> Updating module /home/user/contrail-infra/vendor/sudo
   INFO     -> Updating module /home/user/contrail-infra/vendor/timezone
   INFO     -> Updating module /home/user/contrail-infra/vendor/python
   INFO     -> Updating module /home/user/contrail-infra/vendor/git
   INFO     -> Updating module /home/user/contrail-infra/vendor/puppet

.. [4] directories to load modules from are defined in environment.conf,
   which is then used by puppet master to create a loadpath during execution.
   Some tools can also make use of this to find modules for processing.
.. [5] While some tools (like librarian-puppet) can be made to manage
   dependencies, this is not foolproof and can fail where relation between
   all the modules gets more complicated. Additionally, defining dependencies
   explicitly gives us more control over what we are deploying without
   introducing auto-generated "lock" files into the repository.

Syntax checks and linting
~~~~~~~~~~~~~~~~~~~~~~~~~

Ruby uses rake_ for running tasks, and rake provides a set of tasks for
linting and verifying Puppet and Hiera code (manifests, templates and yaml
files). Those checks can be executed by running
:sh-shell:`rake lint && rake syntax` - this will run both puppet-lint and
puppet-syntax tools and report back any issues with the code.

The same set of tests is running as part of the merge process,
and it's recommended that that invocation is included as part of the
`pre-commit` git hook, to test code before it's been commited and pushed.

.. _rake: https://ruby.github.io/rake/