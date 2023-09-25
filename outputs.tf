output "kubeadm_cynapse_vpc_arn" {
  value = resource.aws_vpc.kubeadm_cynapse_vpc.arn
}

output "kubeadm_cynapse_vpc_id" {
  value = resource.aws_vpc.kubeadm_cynapse_vpc.id
}

# output "kubeadm_cynapse_master_subnet_id" {
#   value = resource.aws_subnet.kubeadm_master_subnet.cidr_block
# }

# output "kubeadm_cynapse_worker01_subnet" {
#   value = resource.aws_subnet.kubeadm_worker01_subnets.cidr_block
# }

# output "kubeadm_cynapse_worker02_subnet" {
#   value = resource.aws_subnet.kubeadm_worker02_subnets.cidr_block
# }

output "kubeadm_cynapse_master_node_public_ip" {
  value = resource.aws_instance.kubeadm_cynapse_control_plane.public_ip
}

output "kubeadm_cynapse_worker_nodes_public_ip" {
  value = resource.aws_instance.kubeadm_cynapse_worker_nodes[*].public_ip
  # value = two(aws_instance.kubeadm_cynapse_worker_nodes[*].public_ip)
}