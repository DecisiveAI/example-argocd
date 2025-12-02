variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  type        = string
  description = "The host of the EKS cluster"
}

variable "oidc_provider" {
  description = "The URL of the OIDC provider"
  type        = string
  sensitive   = true
}

variable "oidc_provider_arn" {
  type        = string
  description = "The ARN of the OIDC provider"
  sensitive   = true
}

variable "cluster_certificate_authority_data" {
  description = "The cluster CA data"
  type        = string
  sensitive   = true
}

variable "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "EXAMPLE_ARGOCD"
}

# ArgoCD Config
variable "argocd_namespace" {
  description = "Name of the ArgoCD namespace"
  type        = string
  default     = "argocd"
}

variable "argocd_version" {
  description = "Helm chart version of ArgoCD"
  type        = string
  default     = "8.5.0"
}

variable "argocd_repo_url" {
  description = "Repository root URL that will be monitored by ArgoCD"
  type        = string
  default     = "https://github.com/DecisiveAI"
}

variable "argocd_gh_cred" {
  description = "ArgoCD GitHub Credential Secret Name"
  type        = string
  default     = "argocd-gh-app-cred"
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

#EBS CSI Driver
variable "ebs_csi_driver_iam" {
  description = "IAM role name to allow EBS CSI driver to do its thing"
  type        = string
  default     = "ebs_csi_driver-irsa"
}

variable "ebs_csi_driver_policy_arn" {
  description = "IAM role name to allow EBS CSI driver to do its thing"
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

variable "ebs_csi_driver_sa" {
  description = "Name of the EBS CSI Driver Service Account"
  type        = string
  default     = "ebs-csi-controller-sa"
}

variable "ebs_csi_driver_namespace" {
  description = "Name of the EBS CSI Driver Service Account"
  type        = string
  default     = "kube-system"
}