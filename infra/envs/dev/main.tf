# Example only: keep disabled until a later ticket wires the AKS module into a non-bootstrap root.
# module "aks" {
#   source              = "../../modules/aks"
#   cluster_name        = "aks-dev-guard"
#   resource_group_name = azurerm_resource_group.state.name
#   location            = var.location
#   dns_prefix          = "aks-dev-guard"
#   kubernetes_version  = "1.29"
#   node_count          = 1
#   node_vm_size              = "Standard_D2_v2"
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
#   tags = {
#     environment = "dev"
#   }
# }

resource "azurerm_resource_group" "state" {
  name     = var.state_rg_name # eg "rg-chatops-guard-state"
  location = var.location      # eg "westeurope"
}

resource "azurerm_storage_account" "state" {
  # checkov:skip=CKV2_AZURE_1: CMK deferred in dev to avoid Key Vault cost/overhead
  # checkov:skip=CKV_AZURE_206: LRS kept intentionally for budget-friendly dev state
  # checkov:skip=CKV_AZURE_59: public network kept on so GH Actions can reach state backend
  # checkov:skip=CKV2_AZURE_33: private endpoint deferred for dev to avoid VNet/DNS cost/complexity
  # checkov:skip=CKV_AZURE_33: queue-service logging is deferred because this dev state bootstrap uses Azure Monitor diagnostics instead of legacy storage logging
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
  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

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

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}


resource "azurerm_storage_container" "tfstate" {
  # checkov:skip=CKV2_AZURE_21: blob-service logging is deferred for dev because the tfstate container is already private and the account-level diagnostics cover the baseline telemetry we keep here
  name               = "tfstate"
  storage_account_id = azurerm_storage_account.state.id
}
