variable "default_network_acl_action" {
  type        = string
  default     = "Deny"
  description = "Sets the default network acl action, should default to Deny."
}

variable "environment" {
  type        = string
  description = "The specific environment"
  validation {
    condition     = contains(["prd", "dev", "tst", "stg", "uat"], lower(var.environment))
    error_message = "Environment must be one of: prd, dev, tst, stg, uat."
  }
}

variable "key_vault_allowed_ips" {
  type        = list(string)
  description = "a list of allowed ips for keyvault"
  default     = null
}

variable "virtual_network_subnet_ids" {
  type        = list(string)
  description = "One or more Subnet IDs which should be able to access this Key Vault"
  default     = null
}

variable "kv_access_policies" {
  type        = any
  description = <<EOT
    list map of access policies

    kv_access_policies = [
    {
      tenant_id = "xxx-xxx-xxx-xxx-xxx"
      object_id = "xxx-xxx-xxx-xxx-xxx"

      key_permissions = [
        "get", "list", "delete", "recover", "backup", "restore", "purge"
      ]

      secret_permissions = [
        "set", "get", "list", "Delete", "Recover", "Backup", "Restore", "purge"
      ]

      storage_permissions = [
        "get"
      ]
      certificate_permissions = [
        "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"
      ]
    }
  ]
  EOT
}

variable "location" {
  type        = string
  description = "Location of the keyvault"
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Defines whether purge protection is enabled on the keyvault. If enabled, keyvault cannot be deleted"
  default     = true
}

variable "purpose" {
  type        = string
  description = "Purpose/workload name (e.g., shared, secrets, certs)"
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.purpose))
    error_message = "Purpose must contain only alphanumeric characters."
  }
}

variable "region" {
  type        = string
  description = "Region code (uks, ukw, euw, neu, use, usw)"
  validation {
    condition     = can(regex("^(uks|ukw|euw|neu|use|usw)$", var.region))
    error_message = "Region must be one of: uks, ukw, euw, neu, use, usw"
  }
}

variable "rgname" {
  type        = string
  description = "The resource group for the keyvault"
}

variable "sku" {
  type        = string
  description = "Keyvault sku"
}

variable "tags" {
  description = "A mapping of tags to assign to the Virtual Machine."
  type        = map(string)

  default = {
    environment = "development"
  }
}

variable "instance" {
  type        = string
  description = "Instance number or unique identifier (e.g., 01, 02, 03)"
  default     = "01"
  validation {
    condition     = can(regex("^[0-9]{2}$", var.instance))
    error_message = "Instance must be a 2-digit number (e.g., 01, 02, 03)."
  }
}

variable "app_shortcode" {
  description = "Application short code (e.g., CRM, ERP, LSH, AUK)"
  type        = string
  default     = ""
  validation {
    condition     = var.app_shortcode == "" || can(regex("^[A-Z]{2,6}$", var.app_shortcode))
    error_message = "App shortcode must be 2-6 uppercase letters or empty string."
  }
}

variable "department" {
  description = "Department responsible for the resource"
  type        = string
  default     = "Platform Engineering"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "CoreServices"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "TBC"
}

variable "rfc" {
  description = "RFC number for change tracking"
  type        = string
  default     = "TBC"
}

variable "expiry_hours" {
  description = "Number of hours from creation until expiry for ExpiryDate tag"
  type        = number
  default     = 26280 # 3 years (24*365*3)
}

variable "update_ring" {
  description = "Update ring priority"
  type        = string
  default     = "Priority"
  validation {
    condition     = contains(["Priority", "Standard", "Extended"], var.update_ring)
    error_message = "Update ring must be one of: Priority, Standard, Extended."
  }
}