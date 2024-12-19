#!/usr/bin/env bash

set -euo pipefail

ufw allow 6443/tcp
ufw allow 2379:2380/tcp
ufw allow 10250/tcp
ufw allow 10257/tcp
ufw allow 10259/tcp

ufw allow 179/tcp
ufw allow 4789/udp
ufw allow 51820:51821/tcp

kubeadm config images pull

kubeadm init --apiserver-advertise-address=192.168.56.10 --pod-network-cidr=10.244.0.0/16

home_path="/home/vagrant"
config_path="/vagrant/conf"
script_path="/vagrant/scripts"

mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

mkdir -p $home_path/.kube
cp /etc/kubernetes/admin.conf $home_path/.kube/config
chown $(id vagrant -u):$(id vagrant -g) $home_path/.kube/config

cp /etc/kubernetes/admin.conf $config_path/config

echo -e "#!/usr/bin/env bash\n">$script_path/join.sh
kubeadm token create --print-join-command>>$script_path/join.sh
chmod +x $script_path/join.sh

kubectl create -f $config_path/kube-flannel.yaml
