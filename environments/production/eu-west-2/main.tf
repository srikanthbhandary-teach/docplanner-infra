terraform {
backend "s3" {
    bucket         = "docplanner-infra-state"
    key            = "prod/eu-west-2/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "docplanner-infra-state-lock"
}
}

provider "aws" {
  region = "eu-west-2"
}

module "eks_vpc" {
  source                     = "github.com/srikanthbhandary-teach/terraform-eks-vpc?ref=v1.0.1"
  cluster_name               = "docplanner-demo-production"  
  vpc_cidr                   = "10.1.0.0/16"
  availability_zones         = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  subnet_private_cidr_blocks = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  subnet_public_cidr_blocks  = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
}

module "eks_cluster" {            
  source  = "github.com/srikanthbhandary-teach/terraform-eks-cluster?ref=v1.0.0"
  vpc_id = module.eks_vpc.vpc_id
  cluster_name = var.cluster_name
  private_subnet_ids = module.eks_vpc.private_subnet_ids
  tags = var.tags 
}


