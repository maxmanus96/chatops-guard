variable "resource_group_name" {
  description = "Resource group that will contain the Event Grid topic."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "Azure region for the Event Grid topic."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location must not be empty."
  }
}

variable "topic_name" {
  description = "Name of the Event Grid custom topic."
  type        = string

  validation {
    condition     = trimspace(var.topic_name) != ""
    error_message = "topic_name must not be empty."
  }

  validation {
    condition     = length(var.topic_name) <= 50 && can(regex("^[A-Za-z0-9-]+$", var.topic_name))
    error_message = "topic_name must be 50 characters or fewer and contain only letters, numbers, and hyphens."
  }
}

variable "input_schema" {
  description = "Schema expected for events published to the topic."
  type        = string
  default     = "EventGridSchema"

  validation {
    condition     = contains(["EventGridSchema", "CloudEventSchemaV1_0", "CustomEventSchema"], var.input_schema)
    error_message = "input_schema must be EventGridSchema, CloudEventSchemaV1_0, or CustomEventSchema."
  }
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the topic. Keep false until a private endpoint or explicit temporary dev publishing path exists."
  type        = bool
  default     = false
}

variable "local_auth_enabled" {
  description = "Whether local key-based authentication is enabled for the topic. Keep false to prefer Entra ID based publishing."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the Event Grid topic."
  type        = map(string)
  default     = {}
}
