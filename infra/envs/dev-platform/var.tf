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

variable "enable_event_grid" {
  description = "Whether this root should create the first Event Grid custom topic for application events."
  type        = bool
  default     = true
}

variable "event_grid_topic_name" {
  description = "Name of the first Event Grid custom topic used for ChatOps Guard application events."
  type        = string
  default     = "evgt-chatops-guard-dev"

  validation {
    condition     = trimspace(var.event_grid_topic_name) != ""
    error_message = "event_grid_topic_name must not be empty."
  }

  validation {
    condition     = length(var.event_grid_topic_name) <= 50 && can(regex("^[A-Za-z0-9-]+$", var.event_grid_topic_name))
    error_message = "event_grid_topic_name must be 50 characters or fewer and contain only letters, numbers, and hyphens."
  }
}

variable "event_grid_input_schema" {
  description = "Schema expected for events published to the Event Grid topic."
  type        = string
  default     = "EventGridSchema"

  validation {
    condition     = contains(["EventGridSchema", "CloudEventSchemaV1_0", "CustomEventSchema"], var.event_grid_input_schema)
    error_message = "event_grid_input_schema must be EventGridSchema, CloudEventSchemaV1_0, or CustomEventSchema."
  }
}

variable "event_grid_public_network_access_enabled" {
  description = "Whether public network access is enabled for the Event Grid topic. Keep false until a private endpoint or explicit temporary dev publishing path exists."
  type        = bool
  default     = false
}

variable "event_grid_local_auth_enabled" {
  description = "Whether local key-based authentication is enabled for the Event Grid topic. Keep false to prefer Entra ID based publishing."
  type        = bool
  default     = false
}

variable "enable_acr" {
  description = "Whether this root should create the Azure Container Registry for application images. Keep false until the always-on registry cost is accepted."
  type        = bool
  default     = false
}

variable "acr_name" {
  description = "Globally unique Azure Container Registry name for ChatOps Guard application images. Use only letters and numbers."
  type        = string
  default     = "acrchatopsguarddev"

  validation {
    condition     = can(regex("^[A-Za-z0-9]{5,50}$", var.acr_name))
    error_message = "acr_name must be 5-50 characters and contain only letters and numbers."
  }
}

variable "acr_sku" {
  description = "ACR SKU. Basic is the budget-friendly dev/demo default; Standard or Premium should be explicit upgrades."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku must be Basic, Standard, or Premium."
  }
}

variable "acr_admin_enabled" {
  description = "Whether the ACR admin user is enabled. Keep false and use Entra ID/RBAC instead of registry passwords."
  type        = bool
  default     = false
}

variable "acr_public_network_access_enabled" {
  description = "Whether public network access is enabled for ACR. For the budget Basic path this stays true and is protected by Entra ID/RBAC; private endpoints require a later Premium decision."
  type        = bool
  default     = true
}

variable "acr_anonymous_pull_enabled" {
  description = "Whether anonymous image pulls are enabled for ACR. Keep false for private application images."
  type        = bool
  default     = false
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

variable "entra_admin_group_object_ids" {
  description = "Dedicated Entra admin group object IDs for AKS access. Use groups, not personal user object IDs, so cluster admin access stays transferable."
  type        = set(string)
  default     = ["06add8f0-84d0-452c-961d-4c8ad96c7391"]

  validation {
    condition     = alltrue([for object_id in var.entra_admin_group_object_ids : trimspace(object_id) != ""])
    error_message = "entra_admin_group_object_ids must not contain empty values."
  }

  validation {
    condition     = !var.enable_aks || length(var.entra_admin_group_object_ids) > 0
    error_message = "entra_admin_group_object_ids must contain at least one dedicated Entra admin group object ID when enable_aks is true."
  }
}

variable "tags" {
  description = "Extra tags to merge into the environment defaults."
  type        = map(string)
  default     = {}
}
