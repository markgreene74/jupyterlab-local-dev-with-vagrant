# jupyter-dev-environment-poc
A POC for building local dev environments for Jupyterlab using Vagrant

See https://github.com/jupyterlab/jupyterlab/issues/12717 for more context.

## TODO
- test on
  - Linux [X]
  - macOS [ ]
  - Windows [ ]

## Overview

This project aims to investigate Vagrant/Virtualbox as a way to easily create, manage and run a local dev environment for Jupyterlab.

## Requirements

- install Vagrant ([link](https://www.vagrantup.com/downloads))
- install Virtualbox ([link](https://www.virtualbox.org/wiki/Downloads))

## Quickstart

- change the GitHub username in [`Vagrant-bootstrap.sh`](Vagrant-bootstrap.sh)
- (optional) edit [`Vagrant-bootstrap.sh`](Vagrant-bootstrap.sh) to change the virtual machine specs (RAM, vCPU)
- run `vagrant up`
- (optional) to capture the provisioning logs run `vagrant up 2>&1 | tee -a vagrant-up-$(date +%F).log` instead
- if successful the output should look like:
  ```shell
  ==> jupyter-dev-environment: This is a local dev environment for Jupyter based on Debian 11 (bullseye)
  ```
- login on the virtual machine with `vagrant ssh`
- run
  ```shell
  cd ~/jupyterlab
  jupyter lab --no-browser --ip 0.0.0.0 --dev-mode --watch
  ```
- copy and past the last link in your browser, it should look like:
  ```shell
  http://127.0.0.1:8888/lab?token=bb4a1ca...
  ```

## Other useful commands

- stop the virtual machine
  ```shell
  vagrant halt
  ```
- remove the virtual machine
  (NOTE: this will completely delete the vm, it will be provisioned from scratch the next time `vagrant up` is executed)
  ```shell
  vagrant destroy
  ```
- check the virtual machine status
  ```shell
  vagrant status
  ```
- re-run the provisioning scripts
  ```shell
  vagrant up --provision
  ```

### snapshots

The ability to take/restore snapshots can be very useful. For more info see: https://www.vagrantup.com/docs/cli/snapshot.

- list the available snapshots
  ```shell
  vagrant snapshot list
  ```
- save and restore, respectively, a snapshot without having to specify a name
  > Warning: If you are using push and pop, avoid using save and restore which are unsafe to mix.
  ```shell
  vagrant snapshot push
  ```
  ```shell
  vagrant snapshot pop
  ```
- save and restore, respectively, a snapshot without having to specify a name
  ```shell
  vagrant snapshot save <SNAPSHOT_NAME>
  ```
  ```shell
  vagrant snapshot restore <SNAPSHOT_NAME>
  ```
