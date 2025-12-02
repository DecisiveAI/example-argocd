variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the EKS cluster will be deployed"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "EXAMPLE_ARGOCD"
}

# Node Group Config
variable "node_ami_type" {
  description = "AMI type for the EKS node group"
  type        = string
  default     = "BOTTLEROCKET_x86_64"
}

variable "node_instance_types" {
  description = "List of instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_types" {
  description = "Capacity types for the EKS node group"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 5
}

variable "node_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 5
}

variable "ebs_csi_driver_policy_arn" {
  description = "IAM role name to allow EBS CSI driver to do its thing"
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}