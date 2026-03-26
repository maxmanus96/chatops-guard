variable "cluster_name" {
  description = "AKS cluster name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will contain the AKS cluster."
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster."
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS API server endpoint."
  type        = string
}

variable "kubernetes_version" {
  description = "Optional AKS Kubernetes version. Leave null to let Azure choose a default supported version."
  type        = string
  default     = null
}

variable "node_count" {
  description = "Initial system node pool size."
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "VM size for the default system node pool."
  type        = string
  default     = "Standard_D2_v2"
}

variable "sku_tier" {
  description = "AKS control plane SKU tier."
  type        = string
  default     = "Free"
}

variable "tags" {
  description = "Tags to apply to the AKS cluster."
  type        = map(string)
  default     = {}
}
