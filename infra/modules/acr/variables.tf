variable "resource_group_name" {
  description = "Resource group that will contain the Azure Container Registry."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "Azure region for the Azure Container Registry."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location must not be empty."
  }
}

variable "registry_name" {
  description = "Globally unique Azure Container Registry name. Use only letters and numbers."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9]{5,50}$", var.registry_name))
    error_message = "registry_name must be 5-50 characters and contain only letters and numbers."
  }
}

variable "sku" {
  description = "ACR SKU. Basic is the budget-friendly demo default; Standard/Premium should be deliberate upgrades."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be Basic, Standard, or Premium."
  }
}

variable "admin_enabled" {
  description = "Whether the ACR admin user is enabled. Keep false and use Entra ID/RBAC instead of registry passwords."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled. Basic keeps cost low but does not provide the private endpoint path used by Premium."
  type        = bool
  default     = true
}

variable "anonymous_pull_enabled" {
  description = "Whether anonymous image pulls are enabled. Keep false for private application images."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the Azure Container Registry."
  type        = map(string)
  default     = {}
}
