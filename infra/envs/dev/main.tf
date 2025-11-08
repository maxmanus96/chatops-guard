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

resource "azurerm_storage_account" "state" {
  name                          = var.state_sa_name # 3–24 lower-case
  resource_group_name           = azurerm_resource_group.state.name
  location                      = azurerm_resource_group.state.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  public_network_access_enabled = true
  min_tls_version               = "TLS1_2"

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

}

resource "azurerm_storage_container" "tfstate" {
  name               = "tfstate"
  storage_account_id = azurerm_storage_account.state.id
}
