resource "azurerm_eventgrid_topic" "this" {
  name                          = var.topic_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  input_schema                  = var.input_schema
  public_network_access_enabled = var.public_network_access_enabled
  local_auth_enabled            = var.local_auth_enabled
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }
}
