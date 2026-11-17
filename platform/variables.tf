variable "subscription_id" {
  type        = string
  description = "Non-prod AI subscription ID."
}

variable "tenant_id" {
  type        = string
  description = "Entra tenant ID."
}

variable "location" {
  type        = string
  description = "Approved Azure region, for example westus3."
}

variable "resource_group_name" {
  type        = string
  description = "AI foundation resource group. The module creates it; it must not already exist."
}

variable "name_prefix" {
  type        = string
  description = "Naming prefix, 10 characters or fewer, lowercase letters and digits."
}

variable "tags" {
  type        = map(string)
  description = "Required tags."
}

variable "existing_vnet_resource_id" {
  type        = string
  description = "Resource ID of the existing non-prod /20 VNet that the network team created and linked to the hub."
}

variable "dns_zones_resource_group_id" {
  type        = string
  description = "Resource ID of the resource group that holds the existing private DNS zones."
}

variable "pe_dns_registration_by_policy" {
  type        = bool
  default     = true
  description = "true = your Azure Policy registers private endpoint DNS records. false = the module registers them itself."
}

variable "project_name" {
  type        = string
  description = "Foundry project name."
}

variable "project_display_name" {
  type        = string
  description = "Foundry project display name."
}

variable "project_description" {
  type        = string
  description = "Foundry project description."
}

variable "apim_publisher_email" {
  type        = string
  description = "Gateway owner mailbox (not a personal address)."
}

variable "apim_publisher_name" {
  type        = string
  description = "Gateway owner display name."
}

variable "apim_sku_root" {
  type        = string
  default     = "Developer"
  description = "Gateway tier. Module default is Premium."
}

variable "apim_sku_capacity" {
  type        = number
  default     = 1
  description = "Gateway units. Module default is 3."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "AVM telemetry. Set per your policy."
}
