
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

/*
  Creates a custom VPC with a single NAT gateway in three private subnets
  and a single Internet Gateway attached to three public subnets.
  
  Note: This VPC is handcrafted for demonstration purposes and can be further improved.
        One way to do this using the `terraform-aws-modules/security-group/aws`
        for simplifying security group creation.    
*/

module "eks_vpc" {
  source                     = "github.com/srikanthbhandary-teach/terraform-eks-vpc?ref=v1.0.0"
  cluster_name               = var.cluster_name
  vpc_cidr                   = "10.1.0.0/16"
  availability_zones         = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  subnet_private_cidr_blocks = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  subnet_public_cidr_blocks  = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
  region                     = var.region
  # The current version of the module does not include support for specifying database subnets.
  # However, adding this feature to the module would enhance its flexibility and usefulness.
}


/* 
  Creates an Amazon EKS cluster with managed nodes.
  The minimum size is set to two nodes. It is noted that to run ArgoCD, 
  there are pod affinity rules requiring a minimum of two nodes for full functionality.
*/
module "eks_cluster" {
  source             = "github.com/srikanthbhandary-teach/terraform-eks-cluster?ref=v1.0.2"
  vpc_id             = module.eks_vpc.vpc_id
  cluster_name       = var.cluster_name
  private_subnet_ids = module.eks_vpc.private_subnet_ids
  min_size           = 2
  tags               = var.tags
  cluster_version    = var.cluster_version
}

/* 
  Adds the Cluster Autoscaler to the Kubernetes cluster.

  This function also leverages the same module to install additional components 
  such as the Karpenter and LoadBalancer Controller.

  TODO: Consider moving this functionality to github.com/srikanthbhandary-teach/terraform-eks-cluster

  Note: Cluster Autoscaler helps in automatically adjusting the size of the Kubernetes cluster 
  based on the resource usage. 
  
  For other addons: https://github.com/aws-ia/terraform-aws-eks-blueprints-addons
*/

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