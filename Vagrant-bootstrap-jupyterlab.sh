#! /usr/bin/env bash
set -euxo pipefail

# NOTE: this bootstrap need to be execute as the vagrant user

### git configuration

# CHANGEME if you wish to use a fork replace GITHUB_USERNAME with your username before provisioning,
#  otherwise the main repo (https://github.com/jupyterlab/jupyterlab.git) will be used
export GITHUB_USERNAME="jupyterlab"

### env variables

export VM_USER=vagrant
export VM_USER_HOME=/home/${VM_USER}

### additional vagrant user configuration

# write the instructions file, make so it is called after each login,
# add a custom section to bashrc

cat << EOF > /home/vagrant/instructions.txt
See https://github.com/jupyterlab/jupyterlab/blob/master/docs/source/developer/contributing.rst#setting-up-a-local-development-environment

- Change directory to 'jupyterlab'

    cd ~/jupyterlab/

- Run JupyterLab
Start JupyterLab in development mode:

    jupyter lab --no-browser --ip 0.0.0.0 --dev-mode

Development mode ensures that you are running the JavaScript assets that are built in the dev-installed Python package. Note that when running in dev mode, extensions will not be activated by default.

When running in dev mode, a red stripe will appear at the top of the page; this is to indicate running an unreleased version.

If you want to change the TypeScript code and rebuild on the fly (needs page refresh after each rebuild):

    jupyter lab --no-browser --dev-mode --ip 0.0.0.0  --watch

- Build and Run the Tests

    jlpm run build:testutils
    jlpm test

You can run tests for an individual package by changing to the appropriate package folder:

    cd packages/notebook
    jlpm run build:test
    jlpm test
EOF

export USER_RC_FILE=${VM_USER_HOME}/.bashrc
export COMMENT="# custom steps"
export ADDITIONAL_PATH='' # 'export PATH=$PATH:/my/additional/path'
#export ADDITIONAL_INSTRUCTIONS='cd /vagrant; echo; echo $PWD; echo; ls ; echo; cat $HOME/instructions.txt; echo'
export ADDITIONAL_INSTRUCTIONS='echo; echo $PWD; echo; ls ; echo; cat $HOME/instructions.txt; echo'

if ! grep -qFx "${COMMENT}" ${USER_RC_FILE}; then
  echo -e "\n${COMMENT}\n# ${ADDITIONAL_PATH}\n${ADDITIONAL_INSTRUCTIONS}" | tee -a ${USER_RC_FILE}
fi

### Set up a Jupyterlab local development environment
# see https://github.com/jupyterlab/jupyterlab/blob/master/docs/source/developer/contributing.rst#setting-up-a-local-development-environment

# only clone during the first provisioning
if [[ ! -d jupyterlab ]]; then
  git clone https://github.com/${GITHUB_USERNAME}/jupyterlab.git
  cd jupyterlab
else
  cd jupyterlab
  git pull --rebase
fi

export PATH="$HOME/.local/bin:$PATH"
pip install -e ".[dev,test]"
jlpm install

echo
echo "Please wait, this will take some time ..."

jlpm run build       # Build the dev mode assets (optional)
jlpm run build:core  # Build the core mode assets (optional)
jupyter lab build    # Build the app dir assets (optional)

echo
echo "All done, the Jupyterlab local development environment is ready"
