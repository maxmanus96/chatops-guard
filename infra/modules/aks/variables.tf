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

variable "vnet_subnet_id" {
  description = "Optional subnet ID for the AKS node pool. Leave null while the module stays skeleton-only; set it before any real Azure CNI deployment."
  type        = string
  default     = null

  validation {
    condition     = var.vnet_subnet_id == null || trimspace(var.vnet_subnet_id) != ""
    error_message = "vnet_subnet_id must be null or a non-empty subnet resource ID."
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

variable "local_account_disabled" {
  description = "Whether local AKS admin accounts should be disabled. On Kubernetes 1.25+ this requires managed AAD integration, so the demo default stays false until that slice exists."
  type        = bool
  default     = false

  validation {
    condition     = !var.local_account_disabled || var.entra_integration_enabled
    error_message = "local_account_disabled can only be true when entra_integration_enabled is also true."
  }
}

variable "entra_integration_enabled" {
  description = "Whether managed Entra ID integration should be enabled for the AKS control plane."
  type        = bool
  default     = false

  validation {
    condition     = !var.entra_integration_enabled || (var.entra_tenant_id != null && trimspace(var.entra_tenant_id) != "" && length(var.entra_admin_group_object_ids) > 0)
    error_message = "entra_integration_enabled requires entra_tenant_id and at least one value in entra_admin_group_object_ids."
  }
}

variable "entra_tenant_id" {
  description = "Tenant ID for the managed Entra ID integration. Required when entra_integration_enabled is true."
  type        = string
  default     = null

  validation {
    condition     = var.entra_tenant_id == null || trimspace(var.entra_tenant_id) != ""
    error_message = "entra_tenant_id must be null or a non-empty tenant ID string."
  }
}

variable "entra_admin_group_object_ids" {
  description = "Entra group object IDs that should receive AKS admin access when managed Entra ID integration is enabled."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for object_id in var.entra_admin_group_object_ids : trimspace(object_id) != ""])
    error_message = "entra_admin_group_object_ids must not contain empty values."
  }
}

variable "entra_azure_rbac_enabled" {
  description = "Whether Azure RBAC should authorize Kubernetes access once managed Entra ID integration is enabled. Keep false for the first slice so authentication and local-account hardening land before the broader Azure RBAC rollout."
  type        = bool
  default     = false
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

variable "network_plugin" {
  description = "AKS network plugin. For this repo, Azure CNI is the intended baseline because it supports overlay mode and the later Cilium path."
  type        = string
  default     = "azure"

  validation {
    condition     = trimspace(var.network_plugin) != ""
    error_message = "network_plugin must not be empty."
  }
}

variable "network_plugin_mode" {
  description = "Optional AKS network plugin mode. Overlay is the intended demo baseline because it avoids early subnet IP pressure while keeping the cluster on Azure CNI."
  type        = string
  default     = "overlay"

  validation {
    condition     = trimspace(var.network_plugin_mode) != ""
    error_message = "network_plugin_mode must not be empty."
  }
}

variable "network_policy" {
  description = "AKS network policy engine. Cilium is the intended default for the first real cluster path."
  type        = string
  default     = "cilium"

  validation {
    condition     = trimspace(var.network_policy) != ""
    error_message = "network_policy must not be empty."
  }
}

variable "network_data_plane" {
  description = "AKS network data plane. Cilium is the intended default for this repo's learning path."
  type        = string
  default     = "cilium"

  validation {
    condition     = trimspace(var.network_data_plane) != ""
    error_message = "network_data_plane must not be empty."
  }
}

variable "outbound_type" {
  description = "AKS egress mode. loadBalancer is the cheapest and simplest demo baseline; stronger or more controlled egress can be introduced later with NAT gateway or user-defined routing."
  type        = string
  default     = "loadBalancer"

  validation {
    condition     = contains(["loadBalancer", "managedNATGateway", "userAssignedNATGateway", "userDefinedRouting", "none"], var.outbound_type)
    error_message = "outbound_type must be one of: loadBalancer, managedNATGateway, userAssignedNATGateway, userDefinedRouting, none."
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
