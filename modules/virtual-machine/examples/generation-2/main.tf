# Generation 2 Windows VM Example with Maximum Security Features
# This example demonstrates Generation 2 VM deployment with all security features enabled

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

# Example resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-vm-gen2-example"
  location = "UK South"
}

# Example virtual network and subnet
resource "azurerm_virtual_network" "example" {
  name                = "vnet-gen2-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "subnet-gen2-vms"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Generation 2 Windows VM with maximum security
module "generation_2_vm" {
  source = "../../"

  # Basic configuration
  region          = "uks"
  environment     = "prd"
  purpose         = "sec"
  instance        = "01"
  app_shortcode   = "GEN2"
  rgname          = azurerm_resource_group.example.name
  location        = azurerm_resource_group.example.location
  subnetid        = azurerm_subnet.example.id
  server_count    = 1

  # VM Configuration optimized for Generation 2
  size                         = "Standard_D4s_v5"  # Gen 2 compatible size
  admin_username               = "gen2admin"
  os_disk_storage_account_type = "Premium_LRS"

  # Generation 2 VM Configuration
  enable_generation_2          = true
  enable_secure_boot          = true
  enable_vtpm                 = true
  security_encryption_type    = "DiskWithVMGuestState"  # Maximum security

  # Use Generation 2 compatible image with Azure Edition features
  vm_image = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-g2"  # Azure Edition Gen 2
    version   = "latest"
  }

  # Enhanced Security Configuration
  enable_encryption_at_host    = true
  enable_patch_management      = true
  enable_boot_diagnostics      = true

  # Domain Configuration
  active_directory_domain      = "ad.allwyn.co.uk"
  active_directory_username    = var.ad_username
  active_directory_password    = var.ad_password
  ou_path                      = "OU=Generation2,OU=Servers,DC=ad,DC=allwyn,DC=co,DC=uk"

  # Full Monitoring Suite
  enable_azure_monitor         = true
  enable_dependency_agent      = true
  enable_guest_configuration   = true
  
  # Locale Configuration
  enable_locale_setting        = true

  # Custom tags emphasizing security
  tags = {
    Environment       = "Production"
    Project          = "Generation2VMs"
    SecurityLevel    = "Maximum"
    Generation       = "Gen2"
    Compliance       = "Enhanced"
    Owner           = "Security Team"
  }

  # Enhanced organizational tags
  department       = "IT Security"
  project         = "VM Modernization Gen2"
  cost_center     = "SEC-001"
  rfc            = "RFC-2024-GEN2"
  update_ring     = "Priority"
}

# Example: Standard Generation 2 VM (less security features)
module "standard_generation_2_vm" {
  source = "../../"

  # Basic configuration
  region          = "uks"
  environment     = "dev"
  purpose         = "app"
  instance        = "01"
  app_shortcode   = "STD2"
  rgname          = azurerm_resource_group.example.name
  location        = azurerm_resource_group.example.location
  subnetid        = azurerm_subnet.example.id
  server_count    = 1

  # Standard Generation 2 configuration
  enable_generation_2          = true
  enable_secure_boot          = true
  enable_vtpm                 = true
  security_encryption_type    = "VMGuestStateOnly"  # Standard security

  # Standard Generation 2 image
  vm_image = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"  # Standard Gen 2
    version   = "latest"
  }

  # Domain Configuration
  active_directory_domain      = "ad.allwyn.co.uk"
  active_directory_username    = var.ad_username
  active_directory_password    = var.ad_password

  tags = {
    Environment = "Development"
    Project     = "StandardGen2VMs"
    Generation  = "Gen2"
  }
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
output "generation_2_vm_details" {
  description = "Details of the Generation 2 VMs"
  value = {
    vm_names              = module.generation_2_vm.vm_names
    vm_hostnames          = module.generation_2_vm.vm_hostnames
    private_ip_addresses  = module.generation_2_vm.private_ip_addresses
    admin_username        = module.generation_2_vm.admin_username
    generation_2_features = module.generation_2_vm.generation_2_features
  }
}

output "standard_gen2_vm_details" {
  description = "Details of the standard Generation 2 VMs"
  value = {
    vm_names              = module.standard_generation_2_vm.vm_names
    generation_2_features = module.standard_generation_2_vm.generation_2_features
  }
}

output "security_comparison" {
  description = "Comparison of security features between VMs"
  value = {
    maximum_security_vm = module.generation_2_vm.generation_2_features
    standard_security_vm = module.standard_generation_2_vm.generation_2_features
  }
}

output "admin_passwords" {
  description = "Admin passwords for the VMs (sensitive)"
  value = {
    generation_2_vm = module.generation_2_vm.admin_passwords
    standard_gen2_vm = module.standard_generation_2_vm.admin_passwords
  }
  sensitive = true
}
