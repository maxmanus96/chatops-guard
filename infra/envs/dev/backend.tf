terraform {
  backend "azurerm" {
    resource_group_name  = "rg-chatops-guard-state"
    storage_account_name = "chopsstate123"
    container_name       = "tfstate-dev"
    key                  = "terraform.tfstate"
  }
}