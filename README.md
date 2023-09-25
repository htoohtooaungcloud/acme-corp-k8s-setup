# Create private-key.pem file with write permisssion
touch 

## Steps after provision
## SSH for hosts
ssh -i private-key.pem ubuntu@54.169.18.228
ssh -i private-key.pem ubuntu@13.212.139.199
ssh -i private-key.pem ubuntu@13.229.211.89


# change the permission of the scripts in each server
chmod +x *.sh

# set some host configure in each server
sudo hostnamectl set-hostname master-node01
sudo echo "54.169.18.228  master-node01  master-node01.cynapse.io" >> /etc/hosts
sudo echo "172-31-39-238  master-node01  master-node01.cynapse.io" >> /etc/hosts
sudo echo "13.212.139.199 worker-node01  worker-node01.cynapse.io" >> /etc/hosts
sudo echo "172.31.43.65 worker-node01  worker-node01.cynapse.io" >> /etc/hosts
sudo echo "13.229.211.89 worker-node02  worker-node01.cynapse.io" >> /etc/hosts
sudo echo  "172-31-41-62  worker-node02  worker-node02.cynapse.io" >> /etc/hosts


sudo hostnamectl set-hostname worker-node01
sudo echo "54.169.18.228  master-node01  master-node01.cynapse.io" >> /etc/hosts
sudo echo "172-31-39-238  master-node01  master-node01.cynapse.io" >> /etc/hosts
sudo echo "13.212.139.199 worker-node01  worker-node01.cynapse.io" >> /etc/hosts
sudo echo "172.31.43.65 worker-node01  worker-node01.cynapse.io" >> /etc/hosts
sudo echo "13.229.211.89 worker-node02  worker-node01.cynapse.io" >> /etc/hosts
sudo echo  "172-31-41-62  worker-node02  worker-node02.cynapse.io" >> /etc/hosts

sudo hostnamectl set-hostname worker-node02
sudo echo "54.169.18.228  master-node01  master-node01.cynapse.io" >> /etc/hosts
sudo echo "172-31-39-238  master-node01  master-node01.cynapse.io" >> /etc/hosts
sudo echo "13.212.139.199 worker-node01  worker-node01.cynapse.io" >> /etc/hosts
sudo echo "172.31.43.65 worker-node01  worker-node01.cynapse.io" >> /etc/hosts
sudo echo "13.229.211.89 worker-node02  worker-node01.cynapse.io" >> /etc/hosts
sudo echo  "172-31-41-62  worker-node02  worker-node02.cynapse.io" >> /etc/hosts


--------------------
Testing Phase
--------------------
 sudo kubectl --kubeconfig /etc/kubernetes/admin.conf get pods -A
 
-------------------------
Join to master-node01
-------------------------
sudo kubeadm join 54.169.18.228:6443 --token njimf1.pxbir7lvm7w7qd6s \
	--discovery-token-ca-cert-hash sha256:4613fa29c8ab29a23d254b1ceff7ebe2f3765f1b29d7ba0fa1633ace6c7f9ce1


# test the svc with cilium

# Preperation for longhorn
sudo vi /etc/multipath.conf

blacklist {
    devnode "^sd[a-z0-9]+"
}
sudo systemctl restart multipathd.service
sudo multipath -t

# install jq
sudo apt install jq -y

# download the script to check env to install longhorn (only for master-node01) 
## link https://medium.com/@ramkicse/how-to-install-longhorn-distributed-block-storage-system-for-kubernetes-811f8afc4d8e
wget https://raw.githubusercontent.com/longhorn/longhorn/v1.3.0/scripts/environment_check.sh
chmod +x environment_check.sh
./environment_check.sh

# rectify the errors for nfs-common (all nodes)
sudo apt install nfs-common -y
sudo systemctl status iscsid
sudo systemctl restart iscsid
sudo systemctl enable iscsid
sudo systemctl status iscsid

# test and verity again in worker-node
./environment_check.sh



# mongo applications through kubectl command in app-collection/frontend-backend-mongo
please go the fronedend-backend-mongo app and deploy the necessary yaml file with "kubectl apply -f" 
please creat configmap and secret yaml at first



## Different Monitoring Namespace for Prometheus Operator (kube-prometheus-stack)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm search repo prometheus | grep -i kube-prometheus-stack 
# NAME                                              	CHART VERSION	APP VERSION	DESCRIPTION                                       
# prometheus-community/kube-prometheus-stack        	50.0.0       	v0.67.1    	kube-prometheus-stack collects Kubernetes manif...
helm install kube-prometheus prometheus-community/kube-prometheus-stack -n monitoring
# customize dashboard can be downloaded from here 
https://grafana.com/grafana/dashboards/
https://github.com/prometheus-community/helm-charts/blob/kube-prometheus-stack-51.2.0/charts/kube-prometheus-stack/values.yaml
https://sysdig.com/blog/prometheus-query-examples/


# loki setup
helm search repo loki # we are going to use loki-stack
helm show values grafana/loki-stack > values-1.yaml 
helm install --values values.yaml loki --namespace monitoring grafana/loki-stack
hem list -A

# check the secret of kube-prometheus-grafana application to login thruough webpage
kubectl get secret kube-prometheus-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode 
kubectl get secret loki-promtail -n monitoring -o jsonpath="{.data.promtail\.yaml}" | base64 --decode
# add in grafana new connection http://10-0-2-150.loki.monitoring.svc.cluster.local:3100 to connect to loki

# advanced loki testing 
kubectl get secret loki-promtail -n monitoring -o jsonpath="{.data.promtail\.yaml}" | base64 --decode > promtail.yaml
delete the existing secret loki-promtail and apply new secret --from-file=./promtail.yaml
delete all pod "kubectl delete pod <pod-name> -n monitoring


# loki and promtail setup
helm install promtail grafana/promtail --set "loki.serviceName=loki" -n monitoring

# git setup for gitops
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/cynapse-ai
ssh -T git@github.com

# create git repo via api
curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer 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" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/user/repos \
  -d '{"name":"cynapse-ai-k8s-setup","description":"This is my test repo!","homepage":"https://github.com","private":false,"is_template":true}'


# let install necessary stuffs for argocd 
ubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml
kubectl edit service/argocd-server -n argocd # to NodePort
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode; echo