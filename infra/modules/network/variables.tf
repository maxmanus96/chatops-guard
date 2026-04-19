variable "resource_group_name" {
  description = "Resource group that will contain the network resources."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "Azure region for the network resources."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location must not be empty."
  }
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string

  validation {
    condition     = trimspace(var.vnet_name) != ""
    error_message = "vnet_name must not be empty."
  }
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)

  validation {
    condition     = length(var.vnet_address_space) > 0 && alltrue([for cidr in var.vnet_address_space : trimspace(cidr) != ""])
    error_message = "vnet_address_space must contain at least one non-empty CIDR block."
  }
}

variable "aks_node_subnet_name" {
  description = "Name of the subnet used by the AKS node pool."
  type        = string

  validation {
    condition     = trimspace(var.aks_node_subnet_name) != ""
    error_message = "aks_node_subnet_name must not be empty."
  }
}

variable "aks_node_subnet_prefixes" {
  description = "Address prefixes for the AKS node subnet."
  type        = list(string)

  validation {
    condition     = length(var.aks_node_subnet_prefixes) > 0 && alltrue([for cidr in var.aks_node_subnet_prefixes : trimspace(cidr) != ""])
    error_message = "aks_node_subnet_prefixes must contain at least one non-empty CIDR block."
  }
}

variable "tags" {
  description = "Tags to apply to the network resources."
  type        = map(string)
  default     = {}
}
