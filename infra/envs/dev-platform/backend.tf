terraform {
  # Pin the Terraform version for reproducible deployments.
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name  = "rg-chatops-guard-state"
    storage_account_name = "chatopsstateguard01"
    container_name       = "tfstate"
    key                  = "infra-dev-platform.tfstate"
    use_azuread_auth     = true
  }
}
