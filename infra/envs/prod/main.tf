# module "aks" {
#   source              = "../../modules/aks"
#   cluster_name        = "aks-dev-guard"
#   k8s_version         = "1.29"
#   node_count          = 1
#   enable_keda         = true
#   tags                = local.tags
# }
