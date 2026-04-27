output "id" {
  description = "Resource ID of the Event Grid topic."
  value       = azurerm_eventgrid_topic.this.id
}

output "name" {
  description = "Name of the Event Grid topic."
  value       = azurerm_eventgrid_topic.this.name
}

output "endpoint" {
  description = "Publish endpoint for the Event Grid topic."
  value       = azurerm_eventgrid_topic.this.endpoint
}

output "identity_principal_id" {
  description = "Principal ID of the Event Grid topic system-assigned managed identity."
  value       = azurerm_eventgrid_topic.this.identity[0].principal_id
}
