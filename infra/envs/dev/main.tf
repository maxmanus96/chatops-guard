# module "aks" {
#   source              = "../../modules/aks"
#   cluster_name        = "aks-dev-guard"
#   k8s_version         = "1.29"
#   node_count          = 1
#   enable_keda         = true
#   tags                = local.tags
# }

resource "azurerm_resource_group" "state" {
  name     = var.state_rg_name # eg "rg-chatops-guard-state"
  location = var.location      # eg "westeurope"
}

#tfsec:ignore:CKV_AZURE_206 # LRS kept intentionally for budget-friendly dev state
resource "azurerm_storage_account" "state" {
  name                            = var.state_sa_name # 3–24 lower-case
  resource_group_name             = azurerm_resource_group.state.name
  location                        = azurerm_resource_group.state.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false
  default_to_oauth_authentication = true
  shared_access_key_enabled       = false
  min_tls_version                 = "TLS1_2"

  # network_rules { #
  #   default_action             = "Allow"
  #   ip_rules                   = ["100.0.0.1"]
  # }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "log-chatops-guard-dev"
  location            = azurerm_resource_group.state.location
  resource_group_name = azurerm_resource_group.state.name
  sku                 = "PerGB2018"
  retention_in_days   = 30 # keep dev costs down; bump in prod if needed
}

resource "azurerm_monitor_diagnostic_setting" "state_logs" {
  name                       = "diag-storage-state"
  target_resource_id         = azurerm_storage_account.state.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  # Blob service logs/metrics
  enabled_log {
    category = "AuditEvent"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}


resource "azurerm_storage_container" "tfstate" {
  name               = "tfstate"
  storage_account_id = azurerm_storage_account.state.id
}
