# Kubernetes Managed Applications and Observability Task
1. Install Kubernetes locally on your laptop with the distribution of your choice or feel free to use the cloud environment as well.
2. Install a sample application (of your choice) that connects to a database that is managed by your Kubernetes cluster
3. Push the logs into Prometheus/Loki and show us that you are able to display metrics nicely in Grafana

# Current Architecture for Assignment
![implemented-cynapse-architecture](https://github.com/htoohtooaungcloud/cynapse-ai-k8s-setup/assets/54118047/d926ad1e-21e0-4cbe-9c24-860cd564c680)

# Improvement Architecture
![well-architected-with-cloud-native](https://github.com/htoohtooaungcloud/cynapse-ai-k8s-setup/assets/54118047/d834da25-4ea8-4222-aed6-fe69adf1bd62)


## Task list 
1. Build the infrastructure using terraform and 3 EC2 Instances in the AWS "ap-southeast-1" + VPC + Subnets + IGW + KeyPair + SecurityGroups and others necessary resources.
2. Create the ansible-terraform provider resources for ENVIRONMENT VARIABILE before carry out configuration changes using Ansible.
3. terraform apply and build the infrastructure.
4. Once we done deploying infrastructure in AWS, execute "ansible-playbook -i <file>". (Some of the stages has problem and need to fix. Therefore, stick to manual setup in each server using script files)
5. Run the "common.sh", "master.sh" and join to the master-node from worker-nodes to form kubernetes cluster using Kubeadm Bootstrap setup.
6. We're going to use cilium as CNI and disable the kube-proxy. Cilium is powerful tool which is fueled by eBPF. 
    - (Basically, it allows to run sandbox programs in the Linux Kernel without going back and forth between Kernel space and userspace which is what iptables do)
7. We'll be using cilium as loadbalancer instead of metallb as well. However, need to create AWS Elastic-LoadBalancer and point to the kubernets api server endpoint 6443 to expose service as LoadBalancer. 
    - This is need to be done and compulsory since we using AWS, but as for now let's stick to LoadBalancer from Cilium when we expose the kubernetes services using EC2 Instace Public IP.
8. Tried to install “Distributed Storage System” which is Longhorn but cannot mount to pods due to the EBS storage space. (# Note: Some basic steps are required to install longhorn in every nodes.)
9. Deploy the applications using kubectl command (Mongo-frontend app,  Mongodb app). Using ***Deployment*** for frontend-mongo express app and ***StatefulSet*** for mongo-db app.
10. Deploy the observability applications using helm (Prometheus, Grafana and Grafana Loki). 
    - Note that ***kube-prometheus-stack*** and ***loki-stack*** helm charts should be installed.
11. Expose the service for Prometheus, Grafana, Mongo-express. In this case, I'm using LoadBalancer.
12. Login via Web access and explore how to display the metrics and logs from Grafana
13. Create GitHub repository as a version control system for GitOps (Singel source of truth, Continuous reconciliation)
14. Install ***Argocd*** for GitOps workflow.
15. Use CloudFlare as DNS and mapped the domain with Public IP Address of Nodes as "A" Record.

## Technology and Tech Stack Using for Assignment

* *Terraform* (Infrastructure as Code)
* *Ansible* (Configuration Management)
* *Kubernetes* (Container Orchestation)
* *Cilium* (Container Network Interface)
* *Grafana* (Visualization)
* *Premetheus* (Metrics)
* *Grafana Loki* (Logging)
* *GitHub* (Version Control System)
* *ArgoCD* (GitOps)
* *Mongo-express & Mongo-db* (Business Application)

### Create private-key.pem file and then change to write permisssion only after terraform apply in your vscode 
```
touch private-key.pem
terraform apply
sudo chmod 600 private-key.pem
```
## Verify the host and variable with ansible
```
ansible-inventory -i inventory.yml --graph
ansible-inventory -i inventory.yml --graph --vars
```

### Let's use Ansible to make changes on each server. If any errors occur, manual SSH into the server to make the necessary changes
```
ansible-playbook -i inventory.yml playbook.yml
```

### Steps to do after provision (Read only permission to private-key)
### SSH command to login to server
```
chomd 400 private-key.pem
ssh -i private-key.pem ubuntu@54.169.18.228
ssh -i private-key.pem ubuntu@13.212.139.199
ssh -i private-key.pem ubuntu@13.229.211.89
```

### Change the permission of the scripts file in each server then execute
```
sudo chmod +x *.sh
bash common.sh # for all nodes
bash master.sh # only for master
```

--------------------
### Testing Phase
--------------------
```
sudo kubectl --kubeconfig /etc/kubernetes/admin.conf get pods -A
``` 


### To make kubectl work for your non-root user
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

--------------------------------------------
## Join to master-node01 from worker nodes to form kubernetes cluster
--------------------------------------------
```
sudo kubeadm join <public-ip-master-node>:6443 --token njimf1.pxbir7lvm7w7qd6s \
	--discovery-token-ca-cert-hash sha256:4613fa29c8ab29a23d254b1ceff7ebe2f3765f1b29d7ba0fa1633ace6c7f9ce1
```

## Set the host configuration in each server 
```
sudo hostnamectl set-hostname master-node01
sudo echo "<public-ip-master-node>  master-node01  master-node01.cynapse.io" >> /etc/hosts
sudo echo "172-31-39-238  master-node01  master-node01.cynapse.io" >> /etc/hosts
sudo echo "<public-ip-worker-node01> worker-node01  worker-node01.cynapse.io" >> /etc/hosts
sudo echo "172.31.43.65 worker-node01  worker-node01.cynapse.io" >> /etc/hosts
sudo echo "<public-ip-worker-node02> worker-node02  worker-node01.cynapse.io" >> /etc/hosts
sudo echo  "172-31-41-62  worker-node02  worker-node02.cynapse.io" >> /etc/hosts

sudo hostnamectl set-hostname worker-node01
sudo echo "<public-ip-master-node>  master-node01  master-node01.cynapse.io" >> /etc/hosts
sudo echo "172-31-39-238  master-node01  master-node01.cynapse.io" >> /etc/hosts
sudo echo "<public-ip-worker-node01> worker-node01  worker-node01.cynapse.io" >> /etc/hosts
sudo echo "172.31.43.65 worker-node01  worker-node01.cynapse.io" >> /etc/hosts
sudo echo "<public-ip-worker-node02> worker-node02  worker-node01.cynapse.io" >> /etc/hosts
sudo echo  "172-31-41-62  worker-node02  worker-node02.cynapse.io" >> /etc/hosts

sudo hostnamectl set-hostname worker-node02
sudo echo "<public-ip-master-node>  master-node01  master-node01.cynapse.io" >> /etc/hosts
sudo echo "172-31-39-238  master-node01  master-node01.cynapse.io" >> /etc/hosts
sudo echo "<public-ip-worker-node01> worker-node01  worker-node01.cynapse.io" >> /etc/hosts
sudo echo "172.31.43.65 worker-node01  worker-node01.cynapse.io" >> /etc/hosts
sudo echo "<public-ip-worker-node02> worker-node02  worker-node01.cynapse.io" >> /etc/hosts
sudo echo  "172-31-41-62  worker-node02  worker-node02.cynapse.io" >> /etc/hosts
```

### Preperation for install longhorn
```
sudo vi /etc/multipath.conf

blacklist {
    devnode "^sd[a-z0-9]+"
}

sudo systemctl restart multipathd.service
sudo multipath -t
```

### Install jq
```
sudo apt install jq -y
```

### Download the script to check env to install longhorn (only for master-node01) 
### Link [https://medium.com/@ramkicse/how-to-install-longhorn-distributed-block-storage-system-for-kubernetes-811f8afc4d8e]
```
wget https://raw.githubusercontent.com/longhorn/longhorn/v1.3.0/scripts/environment_check.sh
chmod +x environment_check.sh
./environment_check.sh
```

### Fix the errors for nfs-common (all nodes)
```
sudo apt install nfs-common -y
sudo systemctl status iscsid
sudo systemctl restart iscsid
sudo systemctl enable iscsid
sudo systemctl status iscsid
```

### Test and verity again in worker-nodes
```
./environment_check.sh
```

### Mongo applications deploymemnt through kubectl command in frontend-backend-mongo
please go the fronedend-backend-mongo app directory and deploy the necessary yaml file with "kubectl apply -f" 
please creat configmap and secret yaml at first before you run the deployment and statefulset manifest yaml file.
```
kubectl apply -f mongo-cm.yaml
kubectl apply -f mongo-secret.yaml
kubectl apply -f mongo-express.yaml
kubectl apply -f mongodb-statefulset.yaml
```

### Different Monitoring Namespace for Prometheus Operator (kube-prometheus-stack) 
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm search repo prometheus | grep -i kube-prometheus-stack 
```

### Verify
```
NAME                                              	CHART VERSION	APP VERSION	DESCRIPTION                                       
prometheus-community/kube-prometheus-stack        	50.0.0       	v0.67.1    	kube-prometheus-stack collects Kubernetes manif...
```

### Helm install command for Prometheus (kube-prometheus-stack) in **monitoring** namespace
#### This helm chart deploys everything automatically that we need to get prometheus up and running on the kubernetes cluster
``` 
helm install kube-prometheus prometheus-community/kube-prometheus-stack -n monitoring
```
### Verify
```
helm list -A
kubectl --namespace monitoring get pods -l "release=kube-prometheus"
```

## Loki installation setup
```
helm search repo loki # we are going to use loki-stack
helm show values grafana/loki-stack > values-1.yaml 
helm install --values values.yaml loki --namespace monitoring grafana/loki-stack
hem list -A
```

## Expose the service of the observability applications
```
kubectl edit svc kube-prometheus-kube-prome-alertmanager -n monitoring  # Change from Cluster IP to LoadBalancer
kubectl edit svc kube-prometheus-kube-prome-prometheus -n monitoring # Change from Cluster IP to LoadBalancer
kubectl edit svc kube-prometheus-grafana -n monitoring # Change from Cluster IP to LoadBalancer
```

## Check the secret of kube-prometheus-grafana application to login thruough webpage
```
kubectl get secret kube-prometheus-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode 
kubectl get secret loki-promtail -n monitoring -o jsonpath="{.data.promtail\.yaml}" | base64 --decode
```
> [!NOTE]
> #### Add in grafana new connection http://loki.monitoring.svc.cluster.local:3100 to connect to loki service 
> #### Shouldn't connect to pod since pods are ephemeral

### Advanced loki testing
```
kubectl get secret loki-promtail -n monitoring -o jsonpath="{.data.promtail\.yaml}" | base64 --decode > promtail.yaml
```

### Modification
> Delete the existing secret loki-promtail and apply new secret --from-file=./promtail.yaml
> Delete all pods "kubectl delete pod <pod-name> -n monitoring

### Git setup to access the GitHub for GitOps
```
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/<your-private-key>
ssh -T git@github.com
```

### Create GitHub repo via API but must have to export API key prior from you GitHub Account
```
curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ghp_vU5rX6ROV48o4k0KP0aejmhSmQxxxxxxxxx" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/user/repos \
  -d '{"name":"cynapse-ai-k8s-setup","description":"This is my repo!","homepage":"https://github.com","private":false,"is_template":true}'
```

### Export argocd values.yaml file from helm chart to explore
```
helm show values argo/argocd-apps > values.yaml
```

### Install argocd  
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml
kubectl edit service/argocd-server -n argocd # to LoadBalancer
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode; echo # check the argocd ui login password
kubectl apply -f mongo-argo-secret-pw.yaml # secret must create first
kubectl apply -f mongo-argo/mongo-argocd-app.yaml
```
## Test result for *Observability*

1. Grafana monitoring dashboard (Grafan Loki)
![grafana-loki-screenshot](https://github.com/htoohtooaungcloud/cynapse-ai-k8s-setup/assets/54118047/5e4c7077-1324-4bce-af7c-78d4a33cb11b)

2. Grafana monitoring dashboard (Grafan Prometheus)
![grafan-prometheus](https://github.com/htoohtooaungcloud/cynapse-ai-k8s-setup/assets/54118047/ea4ba660-b5d7-4c9c-a0b8-022b701ad712)

3. Prometheus monitoring dashboard (Prometheus)
![prometheus-screenshot](https://github.com/htoohtooaungcloud/cynapse-ai-k8s-setup/assets/54118047/90d8f88c-e035-4bc6-8b85-271b625e9c24)

4. Prometheus dashboard (Prometheus Alert-Manager)
![prometheus-alert-manager-screenshot](https://github.com/htoohtooaungcloud/cynapse-ai-k8s-setup/assets/54118047/a6d405f1-0302-4d19-a37d-1b374dae4098)

5. ArgoCD monitoring dashboard
![argocd-screenshot](https://github.com/htoohtooaungcloud/cynapse-ai-k8s-setup/assets/54118047/02a995f6-76c0-4de5-a349-0574d0e4f270)


## Customize dashboard for Grafana and Prometheus metric scraping commands can be downloaded from here 
[https://grafana.com/grafana/dashboards/]
[https://github.com/prometheus-community/helm-charts/blob/kube-prometheus-stack-51.2.0/charts/kube-prometheus-stack/values.yaml]
[https://sysdig.com/blog/prometheus-query-examples/]
[https://grafana.com/blog/2023/04/12/how-to-collect-and-query-kubernetes-logs-with-grafana-loki-grafana-and-grafana-agent/]

## Some useful Prometheus Metric Scarping technique
#### Count of pods per cluster and namespace
```
sum by (namespace) (kube_pod_info)
```

#### Query for all the pods that have been restarting
```
sum by (namespace)(changes(kube_pod_status_ready{condition="true"}[5m]))
```

#### Node memory active using gigabytes
```
node_memory_Active_bytes / 1024 / 1024 / 1024

```
#### Node memory active using bytes (Past 5 mins)
```
node_memory_Active_bytes[5m] 

```
#### To plot the "Rate" on the graph
```
rate(node_memory_Active_bytes[5m] )
```

#### Can expand the graph by using "Add Panel" and execute 
```
rate(node_cpu_seconds_total[5m])
```
