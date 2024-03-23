terraform {
backend "s3" {
    bucket         = "docplanner-infra-state"
    key            = "testing/eu-west-2/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "docplanner-infra-state-lock"
}
}


provider "aws" {
  region = "eu-west-2"
}

module "eks_vpc" {
  source                     = "github.com/srikanthbhandary-teach/terraform-eks-vpc?ref=v1.0.1"
  cluster_name               = "docplanner-demo-testing" 
  vpc_cidr                   = "10.2.0.0/16"
  availability_zones         = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  subnet_private_cidr_blocks = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
  subnet_public_cidr_blocks  = ["10.2.4.0/24", "10.2.5.0/24", "10.2.6.0/24"]
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

