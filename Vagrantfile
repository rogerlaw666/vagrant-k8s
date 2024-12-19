# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'rbconfig'


# Change to NAT if needed (BRIDGE is default)
BUILD_MODE = ENV['BUILD_MODE'] || "NAT" 
IP_NW = "192.168.56"
MASTER_IP_START = 10
NODE_IP_START = 20

# Function to detect if the host is Windows
def is_windows?
  RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
end

# Function to get the default network interface handels both windows and linux
def default_bridge_interface
  if is_windows?
    "Intel(R) Ethernet"
  else
    `ip route | grep default | awk '{ print $5 }'`.chomp
  end
end

Vagrant.configure("2") do |config|
  config.vm.box = "bento/debian-12"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 4096
    vb.cpus = 2
  end

  config.vm.define "control-plane" do |node|
    node.vm.hostname = "control-plane"
    if BUILD_MODE == "BRIDGE"
      bridge_interface = default_bridge_interface
      node.vm.network :public_network, bridge: bridge_interface
    else
      node.vm.network "private_network", ip: "#{IP_NW}.#{MASTER_IP_START}"
    end
    node.vm.provision "shell" do |s|
      s.name = "configure-control-plane"
      s.path = "scripts/configure-control-plane.sh"
      s.privileged = true
    end
  end

  (1..2).each do |i|
    hostname = "node-#{'%02d' % i}"
    config.vm.define "#{hostname}" do |node|
      node.vm.hostname = "#{hostname}"
      if BUILD_MODE == "BRIDGE"
        bridge_interface = default_bridge_interface
        node.vm.network :public_network, bridge: bridge_interface
      else
        node.vm.network "private_network", ip: "#{IP_NW}.#{NODE_IP_START + i}"
      end
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 4096
        vb.cpus = 2
      end
      node.vm.provision "shell" do |s|
        s.name = "configure-worker"
        s.path = "scripts/configure-worker.sh"
        s.args = ["#{hostname}"]
        s.privileged = true
      end
    end
  end

  shell_provision_configs = [
    {
      "name" => "disable-swap",
      "path" => "scripts/disable-swap.sh"
    },
    {
      "name" => "install-essential-tools",
      "path" => "scripts/install-essential-tools.sh"
    },
    {
      "name" => "allow-bridge-nf-traffic",
      "path" => "scripts/allow-bridge-nf-traffic.sh"
    },
    {
      "name" => "install-containerd",
      "path" => "scripts/install-containerd.sh"
    },
    {
      "name" => "install-kubeadm",
      "path" => "scripts/install-kubeadm.sh"
    },
    {
      "name" => "update-kubelet-config",
      "path" => "scripts/update-kubelet-config.sh",
      "args" => ["eth1"]
    }
  ]

  shell_provision_configs.each do |cfg|
    config.vm.provision "shell" do |s|
      s.name = cfg["name"]
      s.path = cfg["path"]
      s.privileged = cfg["privileged"] ? cfg["privileged"] : true
      s.args = cfg["args"] ? cfg["args"] : []
    end
  end

  # config.vm.provision "shell", name: "disable-swap", path: "scripts/disable-swap.sh", privileged: true
  # config.vm.provision "shell", name: "install-essential-tools", path: "scripts/install-essential-tools.sh", privileged: true
  # config.vm.provision "shell", name: "allow-bridge-nf-traffic", path: "scripts/allow-bridge-nf-traffic.sh", privileged: true
  # config.vm.provision "shell", name: "install-containerd", path: "scripts/install-containerd.sh", privileged: true
  # config.vm.provision "shell", name: "install-kubeadm", path: "scripts/install-kubeadm.sh", privileged: true
  # config.vm.provision "shell", name: "update-kubelet-config", path: "scripts/update-kubelet-config.sh", args: ["eth1"], privileged: true
end
