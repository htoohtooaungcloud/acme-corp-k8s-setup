resource "aws_security_group" "kubeadm_cynapse_sg_cilium" {
  name = "cilium-cni"
  # vpc_id = aws_vpc.kubeadm_cynapse_vpc.id
  tags = {
    Name = "cilium cni"
  }

  ingress {
    description = "cilium cni"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "kubadm_cynapse_sg_common" {
  name = "common-ports"
  # vpc_id = aws_vpc.kubeadm_cynapse_vpc.id
  tags = {
    Name = "common ports"
  }

  ingress {
    description = "Allow SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # create security for master node 
}
resource "aws_security_group" "kubeadm_cynapse_sg_control_plane" {
  name = "kubeadm-cynapse-control-plane security group"
  # vpc_id = aws_vpc.kubeadm_cynapse_vpc.id
  ingress {
    description = "all allowed"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "control-plane sg"
  }
}
# create security for worker nodes 
resource "aws_security_group" "kubeadm_cynapse_sg_worker_nodes" {
  name = "kubeadm-worker-node security group"
  # vpc_id = aws_vpc.kubeadm_cynapse_vpc.id

  ingress {
    description = "all allowed"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "worker nodes sg"
  }
}