module "aws_eks_vpc" {
  source       = "./modules/vpc"
  vpc_name     = "${var.cluster_name}-vpc"
  cluster_name = var.cluster_name
}

module "aws_eks" {
  source          = "./modules/eks"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.aws_eks_vpc.vpc_id
  private_subnets = module.aws_eks_vpc.private_subnets
}

module "aws_eks_addons" {
  source                             = "./modules/eks_addons"
  cluster_name                       = var.cluster_name
  cluster_version                    = module.aws_eks.cluster_version
  cluster_endpoint                   = module.aws_eks.cluster_endpoint
  oidc_provider                      = module.aws_eks.oidc_provider
  oidc_provider_arn                  = module.aws_eks.oidc_provider_arn
  cluster_certificate_authority_data = module.aws_eks.cluster_certificate_authority_data
  argocd_gh_app_id                   = var.argocd_gh_app_id
  argocd_gh_app_installation_id      = var.argocd_gh_app_installation_id
  argocd_gh_app_private_key          = var.argocd_gh_app_private_key
}