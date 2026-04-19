variable "platform_resource_group_name" {
  description = "Resource group that will contain the dev platform resources such as AKS and its network foundation."
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
  description = "Whether this root should create the AKS cluster. Keep false for the first safe apply so only the platform resource group and network foundation are created."
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
  description = "VM size for the first dev system pool. D2as_v5 is the current cost-aware default because it is materially cheaper than D2_v2 while keeping more memory headroom than the absolute-cheapest A2_v2 candidate."
  type        = string
  default     = "Standard_D2as_v5"
}

variable "vnet_name" {
  description = "Name of the dev platform virtual network."
  type        = string
  default     = "vnet-chatops-guard-dev"

  validation {
    condition     = trimspace(var.vnet_name) != ""
    error_message = "vnet_name must not be empty."
  }
}

variable "vnet_address_space" {
  description = "Address space for the dev platform virtual network."
  type        = list(string)
  default     = ["10.30.0.0/16"]

  validation {
    condition     = length(var.vnet_address_space) > 0 && alltrue([for cidr in var.vnet_address_space : trimspace(cidr) != ""])
    error_message = "vnet_address_space must contain at least one non-empty CIDR block."
  }
}

variable "aks_node_subnet_name" {
  description = "Name of the subnet used by the AKS node pool."
  type        = string
  default     = "snet-aks-nodes"

  validation {
    condition     = trimspace(var.aks_node_subnet_name) != ""
    error_message = "aks_node_subnet_name must not be empty."
  }
}

variable "aks_node_subnet_prefixes" {
  description = "Address prefixes for the AKS node subnet."
  type        = list(string)
  default     = ["10.30.0.0/24"]

  validation {
    condition     = length(var.aks_node_subnet_prefixes) > 0 && alltrue([for cidr in var.aks_node_subnet_prefixes : trimspace(cidr) != ""])
    error_message = "aks_node_subnet_prefixes must contain at least one non-empty CIDR block."
  }
}

variable "log_analytics_workspace_name" {
  description = "Name of the existing Log Analytics workspace used for AKS monitoring."
  type        = string
  default     = "log-chatops-guard-dev"

  validation {
    condition     = trimspace(var.log_analytics_workspace_name) != ""
    error_message = "log_analytics_workspace_name must not be empty."
  }
}

variable "log_analytics_resource_group_name" {
  description = "Resource group that contains the existing Log Analytics workspace used for AKS monitoring."
  type        = string
  default     = "rg-chatops-guard-state"

  validation {
    condition     = trimspace(var.log_analytics_resource_group_name) != ""
    error_message = "log_analytics_resource_group_name must not be empty."
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

  validation {
    condition     = !var.enable_aks || length(var.api_server_authorized_ip_ranges) > 0
    error_message = "api_server_authorized_ip_ranges must be set when enable_aks is true so the first public AKS API is not left unrestricted by accident."
  }
}

variable "tags" {
  description = "Extra tags to merge into the environment defaults."
  type        = map(string)
  default     = {}
}
