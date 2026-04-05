resource "azurerm_kubernetes_cluster" "this" {
  name                   = var.cluster_name
  location               = var.location
  resource_group_name    = var.resource_group_name
  dns_prefix             = var.dns_prefix
  kubernetes_version     = var.kubernetes_version
  sku_tier               = var.sku_tier
  azure_policy_enabled   = true
  local_account_disabled = true

  # Keep the first module version intentionally small.
  # Enable the lowest-friction security defaults now; defer networking and cost-bearing hardening to later tickets.
  default_node_pool {
    name       = "system"
    node_count = var.node_count
    vm_size    = var.node_vm_size
    max_pods   = 50
  }

  oms_agent {
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    msi_auth_for_monitoring_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
