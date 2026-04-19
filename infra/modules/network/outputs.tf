output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "aks_node_subnet_id" {
  description = "Resource ID of the AKS node subnet."
  value       = azurerm_subnet.aks_nodes.id
}

output "aks_node_subnet_name" {
  description = "Name of the AKS node subnet."
  value       = azurerm_subnet.aks_nodes.name
}
