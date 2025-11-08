# Fill up the variables:
variable "state_rg_name" {
  default = "rg-chatops-guard-state" # eg "rg-chatops-guard-state"
}

variable "state_sa_name" {
  default = "chatopsstateguard01" # 3–24 lower-case
}


variable "location" {
  default = "westeurope" # eg "westeurope"
}
