# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  config.vm.define "Master" do |master|
    master.vm.box = "ubuntu/focal64"

    master.vm.hostname = "Master"
    master.vm.network "private_network", ip: "192.168.33.10"

    master.vm.provision :shell, path: "lamp.sh"
  end

  config.vm.define "Slave" do |slave|
    slave.vm.box = "ubuntu/focal64"
    slave.vm.hostname = "slave"
    slave.vm.network "private_network", ip: "192.168.33.11"
  end
end
