variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "containerapp_name" {
  default = "my-containerapp"
}
variable "resource_group_name" {
  default = "rg-gmaldonado"
}

variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
# variable "subscription_id" {}