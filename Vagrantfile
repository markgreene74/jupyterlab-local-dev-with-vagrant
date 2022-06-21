vm_name = "jupyter-dev-environment"

Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox
  config.vm.box = "debian/bullseye64"

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048  # CHANGEME if needed
    v.cpus = 2       # CHANGEME if needed
    v.name = vm_name
  end

  config.vm.disk :disk, size: "10GB", primary: true
  config.vm.network :forwarded_port, guest: 8888, host: 8888
  config.vm.hostname = vm_name
  config.vm.define vm_name

  config.vm.post_up_message = "This is a local dev environment for Jupyter based on Debian 11 (bullseye)"

  config.vm.provision "base", type: "shell", path: "Vagrant-bootstrap.sh"
  config.vm.provision "dev-environment", type: "shell", path: "Vagrant-bootstrap-jupyterlab.sh", privileged: false

end