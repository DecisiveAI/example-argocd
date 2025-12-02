variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "argocd_gh_app_id" {
  description = "ArgoCD GitHub App ID"
  type        = string
  sensitive   = true
}

variable "argocd_gh_app_installation_id" {
  description = "ArgoCD GitHub App installation ID"
  type        = string
  sensitive   = true
}

variable "argocd_gh_app_private_key" {
  description = "ArgoCD GitHub App Private Key"
  type        = string
  sensitive   = true
}


variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  type        = string
  default     = "1.33"
}
