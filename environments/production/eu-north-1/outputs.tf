output "cluster_endpint" {
  value = module.eks_cluster.cluster_endpoint
}

output "cluster_id" {
  value = module.eks_cluster.cluster_id
}


output "oidc_url" {
  value = module.eks_cluster.oidc_provider_arn
}