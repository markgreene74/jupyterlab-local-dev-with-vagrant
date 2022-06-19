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
  # config.vm.network :forwarded_port, guest: 80, host: 8000    # CHANGEME uncomment if extra ports are needed
  # config.vm.network :forwarded_port, guest: 8080, host: 8080  # CHANGEME uncomment if extra ports are needed
  config.vm.network :forwarded_port, guest: 8888, host: 8888
  config.vm.hostname = vm_name
  config.vm.define vm_name

  config.vm.post_up_message = "This is a local dev environment for Jupyter based on Debian 11 (bullseye) ..."  # TODO add more info

  config.vm.provision "base", type: "shell", path: "Vagrant-bootstrap.sh"
  config.vm.provision "custom", type: "shell", inline: "echo placeholder"

end