#! /usr/bin/env bash
set -euxo pipefail

export VM_USER=vagrant
export VM_USER_HOME=/home/${VM_USER}
export PYENV_ROOT=${VM_USER_HOME}/.pyenv

export PYTHON_VERSION="3.10.5" # CHANGEME if need a different version

### helper functions

function pip_update() {
  python3 -m pip install --upgrade setuptools pip
}

function install_build_dependencies(){
  # see https://github.com/pyenv/pyenv/wiki#suggested-build-environment
  apt-get install make build-essential libssl-dev zlib1g-dev \
                  libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
                  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
                  libffi-dev liblzma-dev -y
                  # libncurses5-dev libgdbm-dev libnss3-dev \
                  # libgdbm-compat-dev
}

function install_python_source() {
  # see https://docs.python.org/3/using/unix.html#building-python
  download_url="https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"

  curl ${download_url} -o /tmp/Python-${PYTHON_VERSION}.tgz
  tar xvzf /tmp/Python-${PYTHON_VERSION}.tgz -C /tmp/

  cd /tmp/Python-${PYTHON_VERSION}
  ./configure --enable-optimizations
  make
  make install
}

function install_python_pyenv() {
  # see https://github.com/pyenv/pyenv#basic-github-checkout

  # only clone during the first provisioning
  if [[ ! -d ${PYENV_ROOT} ]]; then
    git clone https://github.com/pyenv/pyenv.git ${PYENV_ROOT}
    #  cd ${PYENV_ROOT} && src/configure && make -C src

    sed -Ei -e '/^([^#]|$)/ {a \
    export PYENV_ROOT="$HOME/.pyenv"
    a \
    export PATH="$PYENV_ROOT/bin:$PATH"
    a \
    ' -e ':a' -e '$!{n;ba};}' ${VM_USER_HOME}/.profile
    echo 'eval "$(pyenv init --path)"' >>${VM_USER_HOME}/.profile

    echo 'eval "$(pyenv init -)"' >> ${VM_USER_HOME}/.bashrc

    # pyenv-virtualenv
    git clone https://github.com/pyenv/pyenv-virtualenv.git ${PYENV_ROOT}/plugins/pyenv-virtualenv
    ${PYENV_ROOT}/bin/pyenv install -v ${PYTHON_VERSION}
  else
    cd ${PYENV_ROOT}
    git pull --rebase
  fi

  chown -R ${VM_USER}:${VM_USER} ${PYENV_ROOT}
  ${PYENV_ROOT}/bin/pyenv --version
}

### apt update, install necessary packages, build dependencies

apt-get update
apt-get upgrade -y
apt-get install vim curl wget zip git -y
install_build_dependencies

### pip (system package)

apt-get install python3-pip python3-venv -y
pip_update

### add a custom section to the motd

cat << EOF > /etc/update-motd.d/99-custom
#!/bin/bash

echo
if [[ -f /vagrant/.with_pyenv ]] && [[ -d /home/vagrant/.pyenv ]]; then
    echo "Python ${PYTHON_VERSION} installed with pyenv (\$(${PYENV_ROOT}/bin/pyenv --version))"
else
    echo "Python ${PYTHON_VERSION} installed from source"
fi
EOF

chmod +x /etc/update-motd.d/99-custom

### nginx

# TODO probably not needed, strictly speaking

# apt-get install nginx -y

# cat << EOF > /etc/nginx/sites-available/default
# server {
#     listen 8080;
#     location / {
#         proxy_pass http://127.0.0.1:12345/;
#     }
# }
# EOF

# systemctl enable nginx
# systemctl restart nginx

### install Python using pyenv or alternatively from the source

if [[ -f /vagrant/.with_pyenv ]]; then
  INSTALL_WITH="pyenv"
else
  INSTALL_WITH="source"
fi

echo "Checking if Python ${PYTHON_VERSION} is installed ..."
if ! [[ $(python3 --version) =~ ${PYTHON_VERSION} ]]; then
  RUN_PYTHON_INST=true
fi

if [[ ${INSTALL_WITH} == "source" ]] && [[ $RUN_PYTHON_INST ]]; then
  echo "Installing Python ${PYTHON_VERSION} (${INSTALL_WITH})"
  install_python_source
  pip_update
elif [[ ${INSTALL_WITH} == "pyenv" ]] && [[ $RUN_PYTHON_INST ]]; then
  echo "Installing Python ${PYTHON_VERSION} (${INSTALL_WITH})"
  install_python_pyenv
else
  echo "Python ${PYTHON_VERSION} is already installed (${INSTALL_WITH})"
fi

### install poetry

# uncomment this section to install poetry
#echo "Installing Poetry"
## see https://python-poetry.org/docs/master/#installing-with-the-official-installer
#
#sudo -u ${VM_USER} bash <<EOF
#  echo "Installing as:"; whoami; echo
#  curl -sSL https://install.python-poetry.org | python3 -
#  export PATH=$PATH:${VM_USER_HOME}/.local/bin
#  poetry --version
#EOF

## Additional steps to provision a Jupyter local dev environment

# TODO NEEDS TESTING!

# install Node.js

apt-get install nodejs npm

# see https://github.com/jupyterlab/jupyterlab/blob/master/docs/source/developer/contributing.rst#setting-up-a-local-development-environment

git clone https://github.com/<your-github-username>/jupyterlab.git
cd jupyterlab
pip install -e ".[test]"
jlpm install
jlpm run build  # Build the dev mode assets (optional)
jlpm run build:core  # Build the core mode assets (optional)
jupyter lab build  # Build the app dir assets (optional)

### final steps

export USER_RC_FILE=${VM_USER_HOME}/.bashrc
export SYSTEM_RC_FILE=/etc/bash.bashrc
export COMMENT="# custom steps"
export ADDITIONAL_PATH='export PATH=$PATH:/home/vagrant/.local/bin'
export ADDITIONAL_INSTRUCTIONS='cd /vagrant; echo; echo $PWD; echo; ls ; echo'

if ! grep -qFx "${COMMENT}" ${USER_RC_FILE}; then
  echo -e "\n${COMMENT}\n# ${ADDITIONAL_PATH}\n${ADDITIONAL_INSTRUCTIONS}" | tee -a ${USER_RC_FILE}
fi

if ! grep -qFx "${COMMENT}" ${SYSTEM_RC_FILE}; then
  echo -e "\n${COMMENT}\n${ADDITIONAL_PATH}" | tee -a ${SYSTEM_RC_FILE}
fi
