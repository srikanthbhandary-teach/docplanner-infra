provider "aws" {
  region = "eu-north-1"
}

module "eks_vpc" {
  source                     = "github.com/srikanthbhandary-teach/terraform-eks-vpc?ref=v1.0.1"
  cluster_name               = "docplanner-demo-production"
  vpc_cidr                   = var.vpc_cidr
  availability_zones         = var.availability_zones
  subnet_private_cidr_blocks = var.subnet_private_cidr_blocks
  subnet_public_cidr_blocks  = var.subnet_public_cidr_blocks
}

module "eks_cluster" {            
  source  = "github.com/srikanthbhandary-teach/terraform-eks-cluster?ref=v1.0.0"
  vpc_id = module.eks_vpc.vpc_id
  cluster_name = var.cluster_name
  private_subnet_ids = module.eks_vpc.private_subnet_ids
  tags = var.tags 
}

module "lb_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${var.cluster_name}-${var.env_name}_eks_lb"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks_cluster.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

