variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "vnet_location" {
  description = "Location of the Virtual Network"
  type        = string
}

variable "vnet_resource_group_name" {
  description = "Resource Group name for the Virtual Network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "vnet_tags" {
  description = "Tags for the Virtual Network"
  type        = map(string)
  default     = {}
}

variable "subnets" {
  description = "Map of subnets to create"
  type = map(object({
    address_prefixes = list(string)
  }))
  default = {}
}
