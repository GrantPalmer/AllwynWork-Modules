variable "region" {
  type        = string
  description = "Region where the resource resides"
  default     = "uks"
  validation {
    condition     = contains(["uks", "ukw", "euw", "neu", "use", "usw"], lower(var.region))
    error_message = "Region must be one of: uks, ukw, euw, neu, use, usw."
  }
}

variable "environment" {
  type        = string
  description = "The specific environment"
  default     = "prd"
  validation {
    condition     = contains(["prd", "dev", "tst", "stg", "uat"], lower(var.environment))
    error_message = "Environment must be one of: prd, dev, tst, stg, uat."
  }
}

variable "purpose" {
  type        = string
  description = "The meaning of the resource (e.g. web)"
}

variable "instance" {
  type        = string
  description = "Instance number of the resource"
  default     = "01"
}

variable "app_shortcode" {
  description = "Application short code (e.g., LSH, AUK)"
  type        = string
  default     = ""
}

variable "subname" {
  description = "Subname for additional identification"
  type        = string
  default     = ""
}

variable "additional_elements" {
  description = "Additional elements for resource naming (e.g., OS for disks)"
  type        = string
  default     = "OS"
}

variable "size" {
  description = "Specifies the size of the Virtual Machine. For Confidential Computing, use DCasv5-series or ECasv5-series."
  default     = "Standard_B2ms"
  validation {
    condition = can(regex("^Standard_", var.size))
    error_message = "VM size must be a valid Azure VM SKU. For Confidential Computing, use DCasv5-series (e.g., Standard_DC2as_v5) or ECasv5-series."
  }
}

variable "enable_confidential_vm" {
  description = "Enable Confidential VM deployment (requires DCasv5 or ECasv5 series VM sizes and Generation 2)"
  type        = bool
  default     = false
}

variable "subnetid" {
  type        = string
  description = "the subnet ID the network card attaches to"
}

variable "tags" {
  description = "A mapping of tags to assign to the Virtual Machine."
  type        = map(string)
  default     = {}
}

variable "enable_timestamp_tags" {
  description = "Enable automatic CreatedDate and ExpiryDate tags"
  type        = bool
  default     = true
}

variable "expiry_hours" {
  description = "Number of hours from creation until expiry for ExpiryDate tag"
  type        = number
  default     = 26280 # 3 years (24*365*3)
}

variable "department" {
  description = "Department responsible for the resource"
  type        = string
  default     = "Platform Engineering"
}

variable "project" {
  description = "Project name for the resource"
  type        = string
  default     = "CoreServices"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "TBC"
}

variable "rfc" {
  description = "RFC number for the deployment"
  type        = string
  default     = "TBC"
}

variable "stop_start_schedule" {
  description = "Schedule for stopping and starting VMs (used for AutoSchedule tag on VMs only)"
  type        = string
  default     = "Weekdays=08:00-18:00 / Weekends=0"
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

variable "rgname" {
  type        = string
  description = "the name of the resource group for the server"
}

variable "location" {
  type        = string
  description = "the location for the deployment"
}

variable "server_count" {
  type        = number
  description = "Server count to create multiple servers"
}

variable "vm_image" {
  type        = map(any)
  description = "VM image configuration. Default uses Generation 2 compatible Windows Server 2022."
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"  # Generation 2 compatible SKU
    version   = "latest"
  }
}

variable "enable_generation_2" {
  description = "Enable Generation 2 VM deployment (recommended for better security and performance)"
  type        = bool
  default     = true
}

variable "enable_secure_boot" {
  description = "Enable Secure Boot for Generation 2 VMs (requires Generation 2 to be enabled)"
  type        = bool
  default     = true
}

variable "enable_vtpm" {
  description = "Enable vTPM (Virtual Trusted Platform Module) for Generation 2 VMs"
  type        = bool
  default     = true
}

variable "security_encryption_type" {
  description = "Security encryption type for Generation 2 VMs. Options: VMGuestStateOnly, DiskWithVMGuestState. Only applies when enable_confidential_vm = true."
  type        = string
  default     = "VMGuestStateOnly"
  validation {
    condition     = contains(["VMGuestStateOnly", "DiskWithVMGuestState"], var.security_encryption_type)
    error_message = "Security encryption type must be one of: VMGuestStateOnly, DiskWithVMGuestState."
  }
}

variable "confidential_vm_disk_encryption_set_id" {
  description = "Disk Encryption Set ID for Confidential VM (required for DiskWithVMGuestState encryption)"
  type        = string
  default     = null
}

variable "active_directory_domain" {
  description = "Active Directory domain to join"
  default     = "ad.allwyn.co.uk"
}

variable "ou_path" {
  default = null
}

variable "active_directory_username" {}

variable "active_directory_password" {}

variable "data_collection_rule_id" {
  description = "Data collection rule ID for Azure Monitor"
  type        = string
  default     = null
}

variable "enable_boot_diagnostics" {
  description = "Enable boot diagnostics for the VM"
  type        = bool
  default     = true
}

variable "enable_patch_management" {
  description = "Enable automatic patch management"
  type        = bool
  default     = true
}

variable "enable_encryption_at_host" {
  description = "Enable encryption at host"
  type        = bool
  default     = true
}

variable "enable_azure_monitor" {
  description = "Enable Azure Monitor Agent extension"
  type        = bool
  default     = true
}

variable "enable_dependency_agent" {
  description = "Enable Dependency Agent extension"
  type        = bool
  default     = true
}

variable "enable_guest_configuration" {
  description = "Enable Guest Configuration extension"
  type        = bool
  default     = true
}

variable "enable_locale_setting" {
  description = "Enable UK locale setting extension"
  type        = bool
  default     = true
}

variable "admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
  default     = "brc-adminuser"
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for the OS disk"
  type        = string
  default     = "StandardSSD_LRS"
  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.os_disk_storage_account_type)
    error_message = "OS disk storage account type must be one of: Standard_LRS, StandardSSD_LRS, Premium_LRS."
  }
}



