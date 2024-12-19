#!/usr/bin/env bash

set -euo pipefail

ufw allow 10250/tcp
ufw allow 10256/tcp
ufw allow 30000:32767/tcp

ufw allow 179/tcp
ufw allow 4789/udp
ufw allow 5473/tcp
ufw allow 51820:51821/tcp

home_path="/home/vagrant"
config_path="/vagrant/conf"
script_path="/vagrant/scripts"

mkdir -p $HOME/.kube
cp $config_path/config $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

mkdir -p $home_path/.kube
cp $config_path/config $home_path/.kube/config
chown $(id vagrant -u):$(id vagrant -g) $home_path/.kube/config

echo -e "#!/usr/bin/env bash\n">$script_path/join.sh
kubeadm token create --print-join-command>>$script_path/join.sh
chmod +x $script_path/join.sh

$script_path/join.sh

kubectl label node $1 node-role.kubernetes.io/edge=""
kubectl label node $1 node-role.kubernetes.io/node=""
