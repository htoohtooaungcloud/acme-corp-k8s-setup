#!/usr/bin/env bash

MASTER_IP="54.169.18.228"
POD_CIDR="10.244.0.0/16"
KUBERNETES_VERSION="1.27.4"

# Pull the kubernetes images
sudo kubeadm config images pull 

# Init Kubernetes
sudo kubeadm init --skip-phases=addon/kube-proxy \
--control-plane-endpoint $MASTER_IP:6443 \
--apiserver-advertise-address=$MASTER_IP  \
--apiserver-cert-extra-sans=$MASTER_IP \
--pod-network-cidr=$POD_CIDR  

# KUBECONFIG for in-VM kubectl usage
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Untaint the control node to be used as a worker too
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl taint nodes --all  node-role.kubernetes.io/control-plane-

# Install helm
sudo snap install helm --classic

# Install Cilium with its helm chart
cilium install --version 1.14.1 --namespace kube-system --set kubeProxyReplacement=strict

# Generete KUBECONFIG on the host
sudo mkdir -p configs
sudo mkdir -p /home/vagrant/.kube
sudo cp -f /etc/kubernetes/admin.conf configs/config
sudo cp -i configs/config /home/vagrant/.kube/
# sudo touch /vagrant/configs/join.sh
# sudo chmod +x /vagrant/configs/join.sh       

# Generete the kubeadm join command on the host
sudo mkdir configs
sudo kubeadm token create --print-join-command | sudo tee configs/join.sh

sleep 100

# upgrade the cilium for loadbalancer
cilium upgrade --version 1.14.1 --namespace kube-system --set kubeProxyReplacement=true --set gatewayAPI.enabled=true --set l2announcements.enabled=true



