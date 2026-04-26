locals {
  tags = merge(
    {
      environment = "dev"
      stack       = "platform"
      managed_by  = "terraform"
    },
    var.tags
  )
}

resource "azurerm_resource_group" "platform" {
  name     = var.platform_resource_group_name
  location = var.location
  tags     = local.tags
}

module "network" {
  source = "../../modules/network"

  resource_group_name      = azurerm_resource_group.platform.name
  location                 = azurerm_resource_group.platform.location
  vnet_name                = var.vnet_name
  vnet_address_space       = var.vnet_address_space
  aks_node_subnet_name     = var.aks_node_subnet_name
  aks_node_subnet_prefixes = var.aks_node_subnet_prefixes
  tags                     = local.tags
}

module "event_grid" {
  count  = var.enable_event_grid ? 1 : 0
  source = "../../modules/event-grid"

  resource_group_name           = azurerm_resource_group.platform.name
  location                      = azurerm_resource_group.platform.location
  topic_name                    = var.event_grid_topic_name
  input_schema                  = var.event_grid_input_schema
  public_network_access_enabled = var.event_grid_public_network_access_enabled
  local_auth_enabled            = var.event_grid_local_auth_enabled
  tags                          = local.tags
}

data "azurerm_log_analytics_workspace" "logs" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_resource_group_name
}

data "azurerm_client_config" "current" {}

# This root is intentionally thin. It owns the environment-level composition
# and passes shared dependencies in as inputs instead of reaching back into the
# live bootstrap root.
#
# Keep AKS behind an explicit feature flag so the first safe apply can create
# only the platform resource group and network foundation before the cluster is enabled.
module "aks" {
  count  = var.enable_aks ? 1 : 0
  source = "../../modules/aks"

  cluster_name        = var.cluster_name
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  dns_prefix          = var.dns_prefix

  kubernetes_version = var.kubernetes_version
  node_count         = var.node_count
  node_vm_size       = var.node_vm_size
  vnet_subnet_id     = module.network.aks_node_subnet_id

  # For issue #52, move to managed Entra ID with a dedicated admin group.
  # Keep Azure RBAC itself out of this slice so the first change is limited to
  # authentication hardening plus disabling local accounts.
  local_account_disabled          = true
  entra_integration_enabled       = true
  entra_tenant_id                 = data.azurerm_client_config.current.tenant_id
  entra_admin_group_object_ids    = var.entra_admin_group_object_ids
  entra_azure_rbac_enabled        = false
  private_cluster_enabled         = false
  automatic_upgrade_channel       = "patch"
  network_plugin                  = "azure"
  network_plugin_mode             = "overlay"
  network_policy                  = "cilium"
  network_data_plane              = "cilium"
  outbound_type                   = "loadBalancer"
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges

  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs.id
  tags                       = local.tags
}
