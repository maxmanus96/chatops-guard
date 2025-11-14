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
  allow_blob_public_access        = false
  allow_nested_items_to_be_public = false
  default_to_oauth_authentication = true
  shared_access_key_enabled       = false
  min_tls_version                 = "TLS1_2"

  blob_properties {
    versioning_enabled = true
    logging {
      delete  = true
      read    = true
      write   = true
      version = "2.0"
      retention_policy {
        days = 7
      }
    }
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  queue_properties {
    logging {
      delete  = true
      read    = true
      write   = true
      version = "1.0"
      retention_policy {
        days = 7
      }
    }
  }

}

resource "azurerm_storage_container" "tfstate" {
  name               = "tfstate"
  storage_account_id = azurerm_storage_account.state.id
}
