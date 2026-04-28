output "platform_resource_group_name" {
  description = "Resource group used by the dev platform root."
  value       = azurerm_resource_group.platform.name
}

output "vnet_id" {
  description = "Virtual network resource ID for the dev platform root."
  value       = module.network.vnet_id
}

output "vnet_name" {
  description = "Virtual network name for the dev platform root."
  value       = module.network.vnet_name
}

output "aks_node_subnet_id" {
  description = "AKS node subnet resource ID."
  value       = module.network.aks_node_subnet_id
}

output "aks_node_subnet_name" {
  description = "AKS node subnet name."
  value       = module.network.aks_node_subnet_name
}

output "log_analytics_workspace_id" {
  description = "Existing Log Analytics workspace resource ID used by AKS monitoring."
  value       = data.azurerm_log_analytics_workspace.logs.id
}

output "event_grid_topic_id" {
  description = "Event Grid topic resource ID for application events."
  value       = var.enable_event_grid ? module.event_grid[0].id : null
}

output "event_grid_topic_name" {
  description = "Event Grid topic name for application events."
  value       = var.enable_event_grid ? module.event_grid[0].name : null
}

output "event_grid_topic_endpoint" {
  description = "Event Grid topic publish endpoint for application events."
  value       = var.enable_event_grid ? module.event_grid[0].endpoint : null
}

output "event_grid_identity_principal_id" {
  description = "Principal ID of the Event Grid topic system-assigned managed identity."
  value       = var.enable_event_grid ? module.event_grid[0].identity_principal_id : null
}

output "acr_id" {
  description = "Azure Container Registry resource ID."
  value       = var.enable_acr ? module.acr[0].id : null
}

output "acr_name" {
  description = "Azure Container Registry name."
  value       = var.enable_acr ? module.acr[0].name : null
}

output "acr_login_server" {
  description = "Azure Container Registry login server used for image tags."
  value       = var.enable_acr ? module.acr[0].login_server : null
}

output "aks_id" {
  description = "AKS cluster resource ID."
  value       = var.enable_aks ? module.aks[0].id : null
}

output "aks_name" {
  description = "AKS cluster name."
  value       = var.enable_aks ? module.aks[0].name : null
}

output "aks_fqdn" {
  description = "AKS API server FQDN."
  value       = var.enable_aks ? module.aks[0].fqdn : null
}

output "aks_node_resource_group" {
  description = "Managed resource group created by AKS."
  value       = var.enable_aks ? module.aks[0].node_resource_group : null
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet identity for later ACR or Key Vault access rules."
  value       = var.enable_aks ? module.aks[0].kubelet_identity_object_id : null
}
