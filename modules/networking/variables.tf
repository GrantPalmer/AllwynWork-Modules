# Naming convention variables
variable "region" {
  type        = string
  description = "Short region code where the resource resides (e.g., uks, ukw, euw, neu, use, usw)"
  validation {
    condition     = can(regex("^(uks|ukw|euw|neu|use|usw)$", var.region))
    error_message = "Region must be one of: uks, ukw, euw, neu, use, usw"
  }
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, test, prod)"
  validation {
    condition     = can(regex("^(dev|test|uat|stg|prod)$", var.environment))
    error_message = "Environment must be one of: dev, test, uat, stg, prod"
  }
}

variable "platform_name" {
  type        = string
  description = "The specific work package or platform name (e.g., lss, mds)"
}

variable "purpose" {
  type        = string
  description = "The purpose or function of the resource (e.g., web, db, api)"
}

variable "app_shortcode" {
  description = "Application short code (e.g., LSH, AUK)"
  type        = string
  default     = ""
}

variable "instance" {
  type        = string
  description = "Instance number or unique identifier"
  default     = "01"
}

# Resource location
variable "location" {
  type        = string
  description = "The Azure region where resources will be created"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where resources will be created"
}

# Virtual Network Configuration
variable "address_space" {
  type        = list(string)
  description = "The address space that is used by the virtual network"
  default     = ["10.0.0.0/16"]
}

variable "dns_servers" {
  description = "List of DNS servers for the VNet. If not specified, Azure-provided DNS will be used"
  type        = list(string)
  default     = []
}

# Subnet Configuration
variable "subnets" {
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string))
      })
    }))
    # NSG Configuration
    nsg_rules = optional(map(object({
      priority                     = number
      direction                    = string
      access                       = string
      protocol                     = string
      source_port_range            = optional(string, "*")
      destination_port_range       = optional(string)
      destination_port_ranges      = optional(list(string))
      source_address_prefix        = optional(string)
      source_address_prefixes      = optional(list(string))
      destination_address_prefix   = optional(string)
      destination_address_prefixes = optional(list(string))
      description                  = optional(string)
    })), {})
    # Route Table Configuration  
    routes = optional(map(object({
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    })), {})
  }))
  description = "Map of subnet configurations with optional NSG rules and routes"
  default     = {}
}

# Global NSG Rules (applied to all subnets)
variable "global_nsg_rules" {
  type = map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = optional(string, "*")
    destination_port_range     = optional(string)
    destination_port_ranges    = optional(list(string))
    source_address_prefix      = optional(string)
    source_address_prefixes    = optional(list(string))
    destination_address_prefix = optional(string)
    destination_address_prefixes = optional(list(string))
    description               = optional(string)
  }))
  description = "Global NSG rules to be applied to all subnets"
  default     = {}
}

# Global Routes (applied to all subnets)  
variable "global_routes" {
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  description = "Global routes to be applied to all subnets"
  default     = {}
}

# Tagging
variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

