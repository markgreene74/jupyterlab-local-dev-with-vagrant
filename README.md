# jupyterlab-local-dev-with-vagrant

A tool to build local development environments for JupyterLab using Vagrant.

See https://github.com/jupyterlab/jupyterlab/issues/12717 for more context.

## TODO
- test on
  - Linux [X]
  - macOS [ ]
  - Windows [ ]

## Overview

This project aims to investigate Vagrant/Virtualbox as a way to create, manage and run a local dev environment for Jupyterlab.

## Requirements

- install Vagrant ([link](https://www.vagrantup.com/downloads))
- install VirtualBox ([link](https://www.virtualbox.org/wiki/Downloads))

*NOTE:* Vagrant is licensed under the MIT License ([see here](https://github.com/hashicorp/vagrant/blob/main/LICENSE)). The VirtualBox base package (source code and platform binaries) is licensed under the GNU General Public License v2 ([see here](https://www.virtualbox.org/wiki/Licensing_FAQ)). 

## Quickstart

- change the `GITHUB_USERNAME` in [`Vagrant-bootstrap-jupyterlab.sh`](Vagrant-bootstrap-jupyterlab.sh) if you wish to work on a fork

- (*OPTIONAL*) edit [`Vagrant-bootstrap.sh`](Vagrant-bootstrap.sh) to change the virtual machine specs (RAM, vCPU)

- run `vagrant up`

- (*OPTIONAL*) to capture the provisioning logs run `vagrant up 2>&1 | tee -a vagrant-up-$(date +%F).log` instead

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

- copy and paste the link containing the token in your browser, the link should look like:
  ```shell
  http://127.0.0.1:8888/lab?token=bb4a1ca...
  ```

## Other useful commands

- stop the virtual machine
  ```shell
  vagrant halt
  ```

- remove the virtual machine
  (NOTE: this will completely delete the vm, which will be re-created and provisioned from scratch the next time `vagrant up` is executed)
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

### Snapshots

The ability to take/restore snapshots can be very useful. For more information see: https://www.vagrantup.com/docs/cli/snapshot.

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

- save and restore, respectively, a specific snapshot
  ```shell
  vagrant snapshot save <SNAPSHOT_NAME>
  ```
  ```shell
  vagrant snapshot restore <SNAPSHOT_NAME>
  ```

## Advanced usage *(Work In Progress)*

*Here be dragons*

In this section we will discuss how Vagrant/VirtualBox can be integrated in a more advanced workflow.

### Use your `git` credentials inside the virtual machine

In this scenario your `git` configuration and credentials will need to be copied inside the virtual machine.

You will be able to `git push` changes upstream when logged in on the virtual machine. 

TBA

### Run `jupyterlab` in the shared `/vagrant` directory

In this scenario there is no need to transfer your `git` configuration and credentials inside the virtual machine.

You will **not** be able to `git push` changes upstream when logged in on the virtual machine. However, as the cloned repo is located in `/vagrant` in the virtual machine then any changes to the code will also be visible to the *host* OS.

You will be able to use `git` and follow your normal workflow on the *host* OS.

TBA

## Troubleshooting

### The environment is too slow / is taking too long to build

The resources assigned to the Vagrant box are limited by default to 2 vCPU and 2 GB of memory.

It is possible to increase the resources by modifying the following lines in the [Vagrantfile](./Vagrantfile#L8-L9):

```
    v.memory = 2048  # CHANGEME if needed
    v.cpus = 2       # CHANGEME if needed
```

Restart the Vagrant box to make the changes effective:

```shell
vagrant halt && vagrant up
```
 