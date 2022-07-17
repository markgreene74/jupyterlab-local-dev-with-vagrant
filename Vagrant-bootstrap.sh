#! /usr/bin/env bash
set -euxo pipefail

### helper functions

function pip_update() {
  python3 -m pip install --upgrade setuptools pip
}

function install_build_dependencies(){
  apt-get install make build-essential libssl-dev zlib1g-dev \
                  libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
                  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
                  libffi-dev liblzma-dev -y
                  # libncurses5-dev libgdbm-dev libnss3-dev \
                  # libgdbm-compat-dev

  # additional dependencies for jupyterlab[test]
  apt-get install libpixman-1-dev libcairo2-dev libpango1.0-dev libgif-dev -y \
                  # libjpeg62-turbo
}

### apt update, install nice-to-have packages and build dependencies

apt-get update
apt-get upgrade -y
apt-get install vim curl wget zip git -y
install_build_dependencies

### pip, venv (system packages)

apt-get install python3-pip python3-venv -y
pip_update

### add a custom section to the motd

cat << EOF > /etc/update-motd.d/99-custom
#!/bin/bash

echo
echo "Python:  \$(python3 --version)"
echo "pip:     \$(pip --version)"
echo "Node.js: \$(node --version)"
echo "yarn:    \$(yarn --version)"
EOF

chmod +x /etc/update-motd.d/99-custom

## Node.js and Yarn

# install Node.js
# see https://github.com/nodesource/distributions/blob/master/README.md#debinstall

curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install nodejs -y

# install yarn
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
apt-get update -y && apt-get install yarn -y

node --version
yarn --version

## Additional steps

# create the directory /usr/share/jupyter
mkdir -p /usr/share/jupyter
chown -R vagrant:vagrant /usr/share/jupyter/

# add a symlink python --> python3
if ! [ -e /usr/bin/python ] ; then
  ln -s /usr/bin/python3 /usr/bin/python
fi