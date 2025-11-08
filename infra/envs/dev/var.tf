# Fill up the variables:
variable "state_rg_name" {
  default = "rg-chatops-guard-state" # eg "rg-chatops-guard-state"
  type    = string
}

variable "state_sa_name" {
  default = "chatopsstateguard01" # 3–24 lower-case
  type    = string
}


variable "location" {
  default = "westeurope" # eg "westeurope"
  type    = string
}