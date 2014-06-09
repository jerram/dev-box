# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box      = 'trusty64'
  config.vm.box_url  = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.hostname = 'ubuntu.dev'
  config.vm.host_name = 'ubuntu.dev'
  config.vm.synced_folder ".", "/vagrant"
  config.vm.network "private_network", ip: "10.2.2.3"
  config.vm.provision :shell, :inline => "echo \"Etc/UTC\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :forwarded_port, guest: 443, host: 8443
  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.network :forwarded_port, guest: 4444, host: 4444
  config.vm.network :forwarded_port, guest: 8000, host: 8000

  config.vm.provider "virtualbox" do |v|
    v.gui = false
    v.name = "Dev Box"
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.provision "shell", path: "provision.sh"
  config.vm.provision "shell", path: "setup-headless-selenium-xvfb.sh"
  #config.vm.provision "shell", path: "angular.sh"
end