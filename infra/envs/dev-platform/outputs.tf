output "platform_resource_group_name" {
  description = "Resource group used by the dev platform root."
  value       = azurerm_resource_group.platform.name
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
