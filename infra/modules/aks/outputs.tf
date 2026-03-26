output "id" {
  description = "AKS cluster resource ID."
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "AKS cluster name."
  value       = azurerm_kubernetes_cluster.this.name
}

output "fqdn" {
  description = "AKS API server FQDN."
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "node_resource_group" {
  description = "Managed resource group created by AKS for cluster infrastructure."
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet identity, useful for later ACR or Key Vault access rules."
  value       = try(azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id, null)
}
