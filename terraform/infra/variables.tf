variable "location" {
  default = "eastus2"
}

variable "resource_group_name" {
  default = "rg-gmaldonado"
}

variable "containerapp_name" {
  default = "my-containerapp"
}

variable "acr_name" {
  default = "acrtfgmaldo" # DEBE ser único a nivel global
}


variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}