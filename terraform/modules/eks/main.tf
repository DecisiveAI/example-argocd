#trivy:ignore:AVD-AWS-0104 # This is just an example to setup EKS
#trivy:ignore:AVD-AWS-0040 # Need to enable public endpoint for terraform
#trivy:ignore:AVD-AWS-0041 # This is just an example to setup EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.cluster_version

  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API"
  endpoint_public_access                   = true

  enabled_log_types = ["api", "authenticator", "audit", "scheduler", "controllerManager"]

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  addons = {
    coredns = {
      most_recent       = true
      resolve_conflicts = "OVERWRITE"
      configuration_values = jsonencode({
        resources = {
          limits = {
            cpu    = "100m"
            memory = "150Mi"
          }
        }
      })
    }
    eks-pod-identity-agent = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        resources = {
          limits = {
            cpu    = "100m"
            memory = "128Mi"
          }
        }
      })
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent       = true
      resolve_conflicts = "OVERWRITE"
      before_compute    = true
    }
  }

  eks_managed_node_groups = {
    example-argocd = {
      ami_type                   = var.node_ami_type
      instance_types             = var.node_instance_types
      capacity_type              = var.node_capacity_types
      min_size                   = var.node_min_size
      max_size                   = var.node_max_size
      desired_size               = var.node_desired_size
      subnet_ids                 = [var.private_subnets[0]]
      iam_role_attach_cni_policy = true
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = var.ebs_csi_driver_policy_arn #IAM policy needed by CSI driver
      }
    }
  }

  node_security_group_tags = {
    Environment = var.environment
    Terraform   = "true"
  }

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
    Terraform   = "true"
  }
}