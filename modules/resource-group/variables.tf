variable "location" {
  type        = string
  description = "Location of the resource group"
}

variable "subscription_name" {
  type        = string
  description = "Full subscription name to parse for naming components (e.g., 'sub_auk_platform_security')"
  default     = ""
}

variable "app_shortcode" {
  description = "Application short code (e.g., evh, sec, sbx) - Required when using subscription_name"
  type        = string
  default     = ""
  validation {
    condition     = var.app_shortcode == "" || (length(var.app_shortcode) >= 2 && length(var.app_shortcode) <= 4)
    error_message = "App shortcode must be between 2-4 characters when provided."
  }
}

variable "environment" {
  type        = string
  description = "The specific environment"
  validation {
    condition     = contains(["prd", "dev", "tst", "stg", "uat"], lower(var.environment))
    error_message = "Environment must be one of: prd, dev, tst, stg, uat."
  }
}

variable "instance" {
  type        = string
  description = "Instance number or unique identifier (e.g., '01', '02')"
  default     = "01"
  validation {
    condition     = can(regex("^[0-9]{2}$", var.instance))
    error_message = "Instance must be a 2-digit number (e.g., '01', '02')."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource group"
  type        = map(string)
  default     = {}
}

# User access management
variable "contributor_users" {
  description = "List of user principal names to assign Contributor role on the resource group"
  type        = list(string)
  default     = []
}

variable "reader_users" {
  description = "List of user principal names to assign Reader role on the resource group"
  type        = list(string)
  default     = []
}

variable "owner_users" {
  description = "List of user principal names to assign Owner role on the resource group"
  type        = list(string)
  default     = []
}

# Legacy variables maintained for backward compatibility
variable "region" {
  type        = string
  description = "Region where the resource resides"
  default     = ""
  validation {
    condition     = var.region == "" || contains(["uks", "ukw", "euw", "neu", "use", "usw"], lower(var.region))
    error_message = "Region must be one of: uks, ukw, euw, neu, use, usw."
  }
}

variable "platform_name" {
  type        = string
  description = "The spefic work package it relates to (e.g. lss, mds)"
  default     = ""
}

variable "purpose" {
  type        = string
  description = "The meaning of the resource (e.g. web)"
  default     = ""
}