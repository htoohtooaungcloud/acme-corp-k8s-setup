resource "aws_vpc" "kubeadm_cynapse_vpc" {
  cidr_block           = var.cynapse_vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    # NOTE: very important to use an uppercase N to set the name in the console
    Name                               = "kubeadm_cynapse_vpc"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}
# create master01 public subnets
resource "aws_subnet" "kubeadm_master_subnet" {
  vpc_id                  = aws_vpc.kubeadm_cynapse_vpc.id
  cidr_block              = var.cynapse_kubeadm_subnets
  map_public_ip_on_launch = true

  tags = {
    Name = "kubeadm_cynapse_pubilc_subnets"
  }
}

# # create worker01 public subnets
# resource "aws_subnet" "kubeadm_worker01_subnets" {
#   vpc_id                  = aws_vpc.kubeadm_cynapse_vpc.id
#   cidr_block              = var.cynapse_subnet_test[1].subnets
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "kubeadm_cynapse_${var.cynapse_subnet_test[1].name}"
#   }
# }

# # create worker02 public subnets
# resource "aws_subnet" "kubeadm_worker02_subnets" {
#   vpc_id                  = aws_vpc.kubeadm_cynapse_vpc.id
#   cidr_block              = var.cynapse_subnet_test[2].subnets
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "kubeadm_cynapse_${var.cynapse_subnet_test[2].name}"
#   }
# }
# create igw
resource "aws_internet_gateway" "kubeadm_cynapse_igw" {
  vpc_id = aws_vpc.kubeadm_cynapse_vpc.id

  tags = {
    Name = "kubeadm cynapse igw"
  }
}
# create routetable for public subnets
resource "aws_route_table" "kubeadm_cynapse_routetable" {
  vpc_id = aws_vpc.kubeadm_cynapse_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kubeadm_cynapse_igw.id
  }

  tags = {
    Name = "kubeadm cynapse igw_rt"
  }
}
# create rt_association (master)
resource "aws_route_table_association" "kubeadm_cynapse_route_association_master" {
  subnet_id      = aws_subnet.kubeadm_master_subnet.id
  route_table_id = aws_route_table.kubeadm_cynapse_routetable.id
}
# # create rt_association (workers)
# resource "aws_route_table_association" "kubeadm_cynapse_route_association_worker1" {
#   subnet_id      = aws_subnet.kubeadm_master_subnet.id
#   route_table_id = aws_route_table.kubeadm_cynapse_routetable.id
# }

# resource "aws_route_table_association" "kubeadm_cynapse_route_association_worker2" {
#   subnet_id      = aws_subnet.kubeadm_worker02_subnets.id
#   route_table_id = aws_route_table.kubeadm_cynapse_routetable.id
# }

resource "tls_private_key" "kubadm_cynapse_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096

  provisioner "local-exec" { # Create a "pubkey.pem" to your computer!!
    command = "echo '${self.public_key_pem}' > ./pubkey.pem"
  }
}

resource "aws_key_pair" "kubeadm_cynapse_key_pair_test" {
  key_name   = var.keypair_cynapse
  public_key = tls_private_key.kubadm_cynapse_private_key.public_key_openssh

  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.kubadm_cynapse_private_key.private_key_pem}' > ./private-key.pem"
  }
}

resource "aws_instance" "kubeadm_cynapse_control_plane" {
  depends_on = [aws_key_pair.kubeadm_cynapse_key_pair_test]
  ami                         = var.ubuntu_ami
  instance_type               = var.master_node_instance_type
  key_name                    = aws_key_pair.kubeadm_cynapse_key_pair_test.key_name
  associate_public_ip_address = true
  security_groups = [
    aws_security_group.kubadm_cynapse_sg_common.name,
    aws_security_group.kubeadm_cynapse_sg_cilium.name,
    aws_security_group.kubeadm_cynapse_sg_control_plane.name,
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = 30
  }
  tags = {
    Name = "kubeadm-master"
    Role = "control plane node"
  }
  provisioner "local-exec" {
    command = "echo 'master ${self.public_ip}' >> ./files/hosts"
  }
  provisioner "file" {
    source      = "scripts/common.sh"
    destination = "/home/ubuntu/common.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./private-key.pem")}"
      host        = "${self.public_ip}"
    }
  }

  provisioner "file" {
    source      = "scripts/master.sh"
    destination = "/home/ubuntu/master.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./private-key.pem")}"
      host        = "${self.public_ip}"
    }
  }
}

# create worker nodes 2 vms
resource "aws_instance" "kubeadm_cynapse_worker_nodes" {
depends_on = [aws_key_pair.kubeadm_cynapse_key_pair_test]
  count                       = var.worker_nodes_count
  ami                         = var.ubuntu_ami
  instance_type               = var.worker_node_instance_type
  key_name                    = aws_key_pair.kubeadm_cynapse_key_pair_test.key_name
  associate_public_ip_address = true
  security_groups = [
    aws_security_group.kubadm_cynapse_sg_common.name,
    aws_security_group.kubeadm_cynapse_sg_cilium.name,
    aws_security_group.kubeadm_cynapse_sg_worker_nodes.name,
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = 30
  }

  tags = {
    Name = "kubeadm-worker-${count.index}"
    Role = "worker node"
  }

  provisioner "local-exec" {
    command = "echo 'worker-${count.index} ${self.public_ip}' >> ./files/hosts"
  }
  provisioner "file" {
    source      = "scripts/common.sh"
    destination = "/home/ubuntu/common.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./private-key.pem")}"
      host        = "${self.public_ip}"
    }
  }
}





