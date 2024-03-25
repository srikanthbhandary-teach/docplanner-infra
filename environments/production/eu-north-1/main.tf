
terraform {
  backend "s3" {
    bucket         = "docplanner-infra-state"
    key            = "prod/eu-north-1/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "docplanner-infra-state-lock"
  }
}

provider "aws" {
  region = "eu-north-1"
}

module "eks_vpc" {
  source                     = "github.com/srikanthbhandary-teach/terraform-eks-vpc?ref=v1.0.0"
  cluster_name               = var.cluster_name
  vpc_cidr                   = "10.1.0.0/16"
  availability_zones         = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  subnet_private_cidr_blocks = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  subnet_public_cidr_blocks  = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
  region                     = var.region
}

module "eks_cluster" {
  source             = "github.com/srikanthbhandary-teach/terraform-eks-cluster?ref=v1.0.2"
  vpc_id             = module.eks_vpc.vpc_id
  cluster_name       = var.cluster_name
  private_subnet_ids = module.eks_vpc.private_subnet_ids
  min_size           = 2
  tags               = var.tags
  cluster_version    = var.cluster_version
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.16.1"

  cluster_name      = var.cluster_name
  cluster_endpoint  = module.eks_cluster.cluster_endpoint
  cluster_version   = var.cluster_version
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn

  enable_cluster_autoscaler = true
  cluster_autoscaler = {
    wait = true
  }
}

