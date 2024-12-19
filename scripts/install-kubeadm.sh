#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

K8S_VERSION=1.30

apt-get update
apt-get install --quiet --yes apt-transport-https ca-certificates curl

export http_proxy=http://192.168.2.100:7890 https_proxy=http://192.168.2.100:7890 all_proxy=http://192.168.2.100:7890 no_proxy=localhost,127.0.0.1/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16

curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key | \
  gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" | \
  tee /etc/apt/sources.list.d/kubernetes.list

unset http_proxy https_proxy all_proxy no_proxy

apt-get update
apt-get install --quiet --yes kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
