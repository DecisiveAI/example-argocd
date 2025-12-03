output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = var.cluster_name
}

output "cluster_version" {
  description = "The version of the EKS cluster"
  value       = var.cluster_version
}

output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider"
  value       = module.eks.oidc_provider_arn
  sensitive   = true
}

output "oidc_provider" {
  description = "The URL of the OIDC provider"
  value       = module.eks.oidc_provider
  sensitive   = true
}

output "cluster_certificate_authority_data" {
  description = "The cluster CA data"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}
