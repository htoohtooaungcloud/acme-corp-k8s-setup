variable "bca-aws-master-region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "ap-southeast-1" # singapore
}

variable "cynapse_vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cynapse_kubeadm_subnets" {
  description = "Subnet for Cynapse VPC"
  type        = string
  default     = "10.0.1.0/24"
}

# variable "cynapse_subnet_test" {
#   description = "List of subnets"
#   type = list(object({
#     name    = string
#     subnets = string
#   }))
#   default = [
#     {
#       name    = "public_subnet01"
#       subnets = "10.0.0.0/24"
#     },
#     {
#       name    = "public_subnet02"
#       subnets = "10.0.1.0/24"
#     },
#     {
#       name    = "public_subnet03"
#       subnets = "10.0.2.0/24"
#     }
#   ]
# }

variable "keypair_cynapse" {
  type        = string
  description = "the name of cynpase keypair"
  default     = "kubeadm_cynapse"
}

variable "ubuntu_ami" {
  type        = string
  description = "the AMI ID of our linux instance"
  default     = "ami-0df7a207adb9748c7"
}

variable "worker_nodes_count" {
  type        = number
  description = "the total number of worker nodes"
  default     = 2
}

variable "master_node_instance_type" {
  type        = string
  description = "the instance type of master node"
  default     = "t2.xlarge"
}

variable "worker_node_instance_type" {
  type        = string
  description = "the instance type of worker node"
  default     = "t2.xlarge"
}
