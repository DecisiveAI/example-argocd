#trivy:ignore:AVD-AWS-0178 # Let's not add VPC flow log for now...
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = var.enable_dns_hostnames
  azs                  = var.azs
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets

  # EKS requires specific tags on subnets for load balancer provisioning
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }

  tags = {
    Name        = var.vpc_name
    Environment = var.environment
    Terraform   = "true"
  }
} 