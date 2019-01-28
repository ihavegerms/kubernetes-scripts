#!/bin/bash

# This script completes the steps required to configure the Kubernetes master node.
# These steps were taken from the Linux Academy (CKA) course, (Setting up your clouster - set up your practice cluster)
# If you ever need the files again, you can re-download it from here: http://f15c9197a2a6f1f71170-a097ff9e4f7e43e09d957e04a9ede535.r9.cf1.rackcdn.com/k8sprep.sh

# Add docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"

# add kubernetes repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# install docker, kubeadm, kubelet, and kubectl
sudo apt-get update
sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu kubelet=1.12.2-00 kubeadm=1.12.2-00 kubectl=1.12.2-00
# set mark on primary infrastructure packages
sudo apt-mark hold docker-ce kubelet kubeadm kubectl

# insert net.bridge.bridge-nf-call-iptables=1 and apply changes
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -pnet.bridge.bridge-nf-call-iptables

# install flannel networking
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml

echo ""
echo ""
echo "/etc/init.d/k8sprep.sh has completed node configuration. Deleting script...'
rm $0
