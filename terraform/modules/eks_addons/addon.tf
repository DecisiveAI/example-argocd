module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~>1.0"

  cluster_name      = var.cluster_name
  cluster_version   = var.cluster_version
  cluster_endpoint  = var.cluster_endpoint
  oidc_provider_arn = var.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
      configuration_values     = file("${path.module}/values/aws-ebs-csi-driver.json")
    }
  }

  enable_argocd = true
  argocd = {
    chart_version   = var.argocd_version
    namespace       = var.argocd_namespace
    cleanup_on_fail = true
    values          = [file("${path.module}/values/argocd.yaml")]
  }
}
