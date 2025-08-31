# Advanced Windows VM Example with Full Monitoring and Security Configuration
# This example demonstrates all the enhanced features including monitoring, security, and domain integration

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Example resource group (you would typically have this already)
resource "azurerm_resource_group" "example" {
  name     = "rg-vm-advanced-example"
  location = "UK South"
}

# Example virtual network and subnet (you would typically have this already)
resource "azurerm_virtual_network" "example" {
  name                = "vnet-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "subnet-vms"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Example Data Collection Rule for Azure Monitor
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-vm-monitoring"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_data_collection_rule" "example" {
  name                = "dcr-windows-vm-monitoring"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.example.id
      name                  = "destination-log"
    }
  }

  data_flow {
    streams      = ["Microsoft-Windows-Event"]
    destinations = ["destination-log"]
  }

  data_sources {
    windows_event_log {
      streams = ["Microsoft-Windows-Event"]
      x_path_queries = [
        "System!*[System[(Level=1 or Level=2 or Level=3)]]",
        "Application!*[System[(Level=1 or Level=2 or Level=3)]]"
      ]
      name = "eventLogsDataSource"
    }
  }
}

# Advanced Windows VM deployment
module "advanced_windows_vm" {
  source = "../../"

  # Basic configuration
  region          = "uks"
  environment     = "dev"
  purpose         = "app"
  instance        = "01"
  app_shortcode   = "ADV"
  rgname          = azurerm_resource_group.example.name
  location        = azurerm_resource_group.example.location
  subnetid        = azurerm_subnet.example.id
  server_count    = 2

  # VM Configuration
  size                         = "Standard_D2s_v3"
  admin_username               = "advadmin"
  os_disk_storage_account_type = "Premium_LRS"

  # Security Configuration
  enable_encryption_at_host    = true
  enable_patch_management      = true
  enable_boot_diagnostics      = true

  # Domain Configuration
  active_directory_domain      = "ad.allwyn.co.uk"
  active_directory_username    = var.ad_username
  active_directory_password    = var.ad_password
  ou_path                      = "OU=Servers,OU=Azure,DC=ad,DC=allwyn,DC=co,DC=uk"

  # Monitoring Configuration
  enable_azure_monitor         = true
  enable_dependency_agent      = true
  enable_guest_configuration   = true
  data_collection_rule_id      = azurerm_monitor_data_collection_rule.example.id

  # Locale Configuration
  enable_locale_setting        = true

  # Custom tags
  tags = {
    Environment    = "Development"
    Project        = "AdvancedVMExample"
    Owner          = "Platform Team"
    Purpose        = "Testing advanced VM features"
    MaintenanceWindow = "Sunday 02:00-04:00"
  }

  # Enhanced tag configuration
  department     = "IT Operations"
  project        = "VM Modernization"
  cost_center    = "IT-001"
  rfc           = "RFC-2024-001"
  update_ring    = "Standard"
}

# Variables for sensitive data
variable "ad_username" {
  description = "Active Directory username for domain join"
  type        = string
  sensitive   = true
}

variable "ad_password" {
  description = "Active Directory password for domain join"
  type        = string
  sensitive   = true
}

# Outputs
output "vm_details" {
  description = "Details of the created VMs"
  value = {
    vm_names              = module.advanced_windows_vm.vm_names
    vm_hostnames          = module.advanced_windows_vm.vm_hostnames
    private_ip_addresses  = module.advanced_windows_vm.private_ip_addresses
    admin_username        = module.advanced_windows_vm.admin_username
    extensions_installed  = module.advanced_windows_vm.extensions_installed
  }
}

output "admin_passwords" {
  description = "Admin passwords for the VMs (sensitive)"
  value       = module.advanced_windows_vm.admin_passwords
  sensitive   = true
}

output "monitoring_configuration" {
  description = "Monitoring configuration details"
  value = {
    log_analytics_workspace = azurerm_log_analytics_workspace.example.name
    data_collection_rule    = azurerm_monitor_data_collection_rule.example.name
    dcr_associations        = module.advanced_windows_vm.dcr_associations
  }
}
