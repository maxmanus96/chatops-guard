terraform {
  #Pin the terraform version for reproducible deployments
  required_version = ">= 1.5.0"
  backend "azurerm" {
    resource_group_name  = "rg-chatops-guard-state"
    storage_account_name = "chatopsstateguard01"
    container_name       = "tfstate"
    key                  = "infra-dev.tfstate"

    # Optional but recommended if your azurerm backend supports it:
    use_azuread_auth = true
  }
}