resource "ansible_host" "kubadm_cynapse_control_plane_ansible_host" {
  depends_on = [
    aws_instance.kubeadm_cynapse_control_plane
  ]
  name   = "control_plane"
  groups = ["master"]
  variables = {
    ansible_user                 = "ubuntu"
    ansible_host                 = aws_instance.kubeadm_cynapse_control_plane.public_ip
    ansible_ssh_private_key_file = "./private-key.pem"
    node_hostname                = "master"
  }
}

resource "ansible_host" "kubadm_cynapse_worker_nodes_ansible_host" {
  depends_on = [
    aws_instance.kubeadm_cynapse_worker_nodes
  ]
  count  = var.worker_nodes_count
  name   = "worker-${count.index}"
  groups = ["workers"]
  variables = {
    node_hostname                = "worker-${count.index}"
    ansible_user                 = "ubuntu"
    ansible_host                 = aws_instance.kubeadm_cynapse_worker_nodes[count.index].public_ip
    ansible_ssh_private_key_file = "./private-key.pem"
  }
}
