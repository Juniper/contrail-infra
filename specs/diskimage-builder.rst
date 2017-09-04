==========================
Diskimage-builder Workflow
==========================

Problem Description
===================

Image Building
--------------

Currently, cloud images used for the OpenContrail build process are created
by spawning a new virtual machine and then, depending on the flavor, either
running a set of shell scripts that install all the dependencies, or doing
that by hand. Finally, a snapshot of the VM is made and it's used for spawning
new builders. This process is slow, due to requiring us to spawn new VM every
time, time consuming and error-prone when manual provisioning is needed.

System dependencies
-------------------

Contrail build process requires a number of system dependencies, some of which
are not available in upstream repositories. Those package dependencies are
not well documented, and are currently handled by installing them on the
builder from shared NFS mount.

Change Proposal
===============

Overview
--------

Builder image will be created using set of tools that modularize changes,
to make them easier to parse, and abstract as much of the difference between
distribution as possible.

OpenStack introduced, as part of the Tripple-O project, a tool called
diskimage-builder (dib), that can be used to create Linux images without having
to boot virtual machine to modify state of the system.

Dib supports all Linux distribution that OpenContrail currently is built for,
as well as other popular flavors like Debian and OpenSuse. There are also
plans to add some level of support for creating Windows images, that could
be leveraged for creating Windows builders for Contrail Windows Docker driver.

Furthermore, nodepool (part of OpenStack CI) depends on dib for creating cloud
images used for gating, and given plans to follow OpenStack example in our
OpenContrail CI refresh, reusing dib seems to be a safe approach.

System Dependencies
-------------------

Packages required by the build process will be gathered into separate apt/yum
repositories, and all changes to those dependencies must be publicly
documented on gerrit, with full trace of source packages, and any custom
patches made to support Contrail. During build process, dib will be configured
to use those repositories, and packages will be installed with yum/apt-get.

Implementation
==============

Diskimage-builder Elements
--------------------------

The existing shell scripts should be transformed into distinct dib elements,
so that resulting images have the same configuration as current ones.

.. code-block::

  +-elements/
    +-disable-selinux/
    +-insecure-docker-registry/
    +-contrail/
    +-ansible/
    +-hosts/

``disable-selinux`` contains CentOS/RedHat code for disabling SELinux, which
is currently recommended to get Docker to run.
``insecure-docker-registry`` handles Docker configuration for using own
registries without proper SSL certificates.
``contrail`` manages packages and other contrail-specific changes.
``ansible`` installs ansible in the correct version.
``hosts`` manages /etc/hosts file.

System Dependencies
-------------------

For each contrail release, and a supported distribution, a corresponding package
repository will be created, with all the dependencies not available in the
system (either missing packages, or too old versions).

Each system dependency will have its own git repository where spec files and
debian "control" directories are stored, with each Contrail release having
its own branch per system:

.. code-block::

  user@host ~/build/libuv $ git branch                                                                                                                                                                                                                                                  ⏎
    R4.0/rhel7
    R4.0/trusty
    R4.0/xenial
  * master/rhel7
    master/xenial

Every branch should have the distribution-specific file layout, based on how
packages are managed upstream, for example:

.. code-block::

  user@host ~/build/libuv $ git checkout -t origin/master/rhel7
  Branch master/rhel7 set up to track remote branch master/rhel7 from origin.
  Switched to a new branch 'master/rhel7'.
  user@host ~/build/libuv $ ls
  libuv.spec
  sources
  user@host ~/build/libuv $ git checkout -t origin/master/xenial
  Branch master/xenial set up to track remote branch master/xenial from origin.
  Switched to a new branch 'master/xenial'
  user@host ~/build/libuv $ ls
  debian/
  user@host ~/build/libuv $ ls debian/
  changelog         clean             compat            control
  copyright         libuv-dev.install libuv1.install    rules
  source