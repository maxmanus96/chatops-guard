variable "platform_resource_group_name" {
  description = "Resource group that will contain the dev platform resources such as AKS."
  type        = string
  default     = "rg-chatops-guard-platform-dev"

  validation {
    condition     = trimspace(var.platform_resource_group_name) != ""
    error_message = "platform_resource_group_name must not be empty."
  }
}

variable "location" {
  description = "Azure region for the dev platform root."
  type        = string
  default     = "westeurope"

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location must not be empty."
  }
}

variable "cluster_name" {
  description = "AKS cluster name for the dev platform root."
  type        = string
  default     = "aks-dev-guard"

  validation {
    condition     = trimspace(var.cluster_name) != ""
    error_message = "cluster_name must not be empty."
  }
}

variable "dns_prefix" {
  description = "DNS prefix for the dev AKS cluster."
  type        = string
  default     = "aks-dev-guard"

  validation {
    condition     = trimspace(var.dns_prefix) != ""
    error_message = "dns_prefix must not be empty."
  }
}

variable "enable_aks" {
  description = "Whether this root should create the AKS cluster. Keep false for the first safe apply so only the platform resource group is created."
  type        = bool
  default     = false
}

variable "kubernetes_version" {
  description = "Optional AKS Kubernetes version. Leave null to let Azure choose a supported default later."
  type        = string
  default     = null
}

variable "node_count" {
  description = "Initial system node-pool size."
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "VM size for the first dev system pool."
  type        = string
  default     = "Standard_D2_v2"
}

variable "vnet_subnet_id" {
  description = "Subnet resource ID for the AKS node pool. Required only when enable_aks is true."
  type        = string
  default     = null

  validation {
    condition     = !var.enable_aks || (var.vnet_subnet_id != null && trimspace(var.vnet_subnet_id) != "")
    error_message = "vnet_subnet_id must be set to a non-empty subnet resource ID when enable_aks is true."
  }
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID used for AKS monitoring. Required only when enable_aks is true."
  type        = string
  default     = null

  validation {
    condition     = !var.enable_aks || (var.log_analytics_workspace_id != null && trimspace(var.log_analytics_workspace_id) != "")
    error_message = "log_analytics_workspace_id must be set to a non-empty workspace resource ID when enable_aks is true."
  }
}

variable "api_server_authorized_ip_ranges" {
  description = "Optional public IP ranges allowed to reach the AKS API server."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.api_server_authorized_ip_ranges : trimspace(cidr) != ""])
    error_message = "api_server_authorized_ip_ranges must not contain empty values."
  }
}

variable "tags" {
  description = "Extra tags to merge into the environment defaults."
  type        = map(string)
  default     = {}
}
