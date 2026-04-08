variable "cluster_name" {
  description = "AKS cluster name."
  type        = string

  validation {
    condition     = trimspace(var.cluster_name) != ""
    error_message = "cluster_name must not be empty."
  }
}

variable "resource_group_name" {
  description = "Resource group that will contain the AKS cluster."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "Azure region for the AKS cluster."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location must not be empty."
  }
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS API server endpoint."
  type        = string

  validation {
    condition     = trimspace(var.dns_prefix) != ""
    error_message = "dns_prefix must not be empty."
  }
}

variable "kubernetes_version" {
  description = "Optional AKS Kubernetes version. Leave null to let Azure choose a default supported version."
  type        = string
  default     = null

  validation {
    condition     = var.kubernetes_version == null || trimspace(var.kubernetes_version) != ""
    error_message = "kubernetes_version must be null or a non-empty version string."
  }
}

variable "node_count" {
  description = "Initial system node pool size."
  type        = number
  default     = 1

  validation {
    condition     = var.node_count >= 1 && floor(var.node_count) == var.node_count
    error_message = "node_count must be a whole number greater than or equal to 1."
  }
}

variable "node_vm_size" {
  description = "VM size for the default system node pool."
  type        = string
  default     = "Standard_D2_v2"

  validation {
    condition     = trimspace(var.node_vm_size) != ""
    error_message = "node_vm_size must not be empty."
  }
}

variable "sku_tier" {
  description = "AKS control plane SKU tier."
  type        = string
  default     = "Free"

  validation {
    condition     = trimspace(var.sku_tier) != ""
    error_message = "sku_tier must not be empty."
  }
}

variable "private_cluster_enabled" {
  description = "Whether the AKS API server should only be exposed on private IP addresses."
  type        = bool
  default     = false
}

variable "automatic_upgrade_channel" {
  description = "AKS automatic upgrade channel. For this demo path, patch is the safest default because it stays on the same minor version while still taking patch releases."
  type        = string
  default     = "patch"

  validation {
    condition     = contains(["patch", "stable", "rapid", "node-image", "none"], var.automatic_upgrade_channel)
    error_message = "automatic_upgrade_channel must be one of: patch, stable, rapid, node-image, none."
  }
}

variable "api_server_authorized_ip_ranges" {
  description = "Optional set of public IP ranges allowed to reach the AKS API server."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.api_server_authorized_ip_ranges : trimspace(cidr) != ""])
    error_message = "api_server_authorized_ip_ranges must not contain empty values."
  }
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace used for AKS monitoring."
  type        = string

  validation {
    condition     = trimspace(var.log_analytics_workspace_id) != ""
    error_message = "log_analytics_workspace_id must not be empty."
  }
}

variable "tags" {
  description = "Tags to apply to the AKS cluster."
  type        = map(string)
  default     = {}
}
