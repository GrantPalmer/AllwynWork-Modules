# Terraform Azure Windows Virtual Machine Module

This module creates Windows virtual machines in Azure with comprehensive security configurations, monitoring extensions, and standardized naming conventions.

## Features

- Creates one or more Windows virtual machines with enhanced security
- **Generation 2 VM Support** with advanced security features:
  - Secure Boot for trusted boot process
  - vTPM (Virtual Trusted Platform Module) support
  - Enhanced security encryption options
- Automatic password generation per VM with secure storage
- Standardized naming conventions for all resources
- Comprehensive tagging strategy with automatic timestamps
- Network interface creation and management
- Domain joining functionality with AD integration
- **Enhanced Security Features:**
  - Encryption at host
  - Automatic patch management
  - Boot diagnostics
- **Monitoring & Management Extensions:**
  - Azure Monitor Agent
  - Dependency Agent
  - Guest Configuration (Azure Policy)
  - Data Collection Rule associations
- **Locale Configuration:**
  - UK locale and timezone settings
- **Configurable Extensions:**
  - All extensions can be enabled/disabled via variables

## Usage

### Basic Configuration
```hcl
module "windows_vm" {
  source = "../../modules/virtual-machine"

  # Required variables
  region          = "uks"
  environment     = "dev"
  purpose         = "web"
  rgname          = "rg-example"
  location        = "UK South"
  subnetid        = "/subscriptions/.../subnets/subnet1"
  server_count    = 2

  # AD Domain Join
  active_directory_domain    = "ad.allwyn.co.uk"
  active_directory_username  = "domain-admin"
  active_directory_password  = var.ad_password
  ou_path                    = "OU=Servers,DC=ad,DC=allwyn,DC=co,DC=uk"

  # Optional configurations
  app_shortcode              = "myapp"
  size                      = "Standard_D2s_v3"
  admin_username            = "localadmin"
  
  tags = {
    Project = "MyProject"
    Owner   = "TeamName"
  }
}
```

### Advanced Configuration with Monitoring
```hcl
module "windows_vm_advanced" {
  source = "../../modules/virtual-machine"

  # ... basic configuration ...

  # Enhanced security
  enable_encryption_at_host     = true
  enable_patch_management       = true
  os_disk_storage_account_type  = "Premium_LRS"

  # Generation 2 VM features (enabled by default)
  enable_generation_2           = true
  enable_secure_boot           = true
  enable_vtpm                  = true
  security_encryption_type     = "VMGuestStateOnly"

  # Monitoring configuration
  enable_azure_monitor         = true
  enable_dependency_agent      = true
  data_collection_rule_id      = "/subscriptions/.../dataCollectionRules/dcr-example"
  
  # Extensions
  enable_guest_configuration   = true
  enable_locale_setting        = true
  enable_boot_diagnostics      = true
}
```

### Generation 2 VM with Maximum Security
```hcl
module "windows_vm_secure" {
  source = "../../modules/virtual-machine"

  # ... basic configuration ...

  # Maximum security configuration
  enable_generation_2           = true
  enable_secure_boot           = true
  enable_vtpm                  = true
  security_encryption_type     = "DiskWithVMGuestState"  # Enhanced encryption
  enable_encryption_at_host     = true
  os_disk_storage_account_type  = "Premium_LRS"

  # Use specific Generation 2 image
  vm_image = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-g2"  # Azure Edition with enhanced features
    version   = "latest"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.116.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.116.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_interface.adds-nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_virtual_machine_extension.join-domain](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_windows_virtual_machine.adds-vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | Region where the resource resides | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The specific environment | `string` | n/a | yes |
| <a name="input_purpose"></a> [purpose](#input\_purpose) | The meaning of the resource (e.g. web) | `string` | n/a | yes |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance number of the resource | `string` | `"01"` | no |
| <a name="input_app_shortcode"></a> [app\_shortcode](#input\_app\_shortcode) | Application short code (e.g., LSH, AUK) | `string` | `""` | no |
| <a name="input_subname"></a> [subname](#input\_subname) | Subname for additional identification | `string` | `""` | no |
| <a name="input_additional_elements"></a> [additional\_elements](#input\_additional\_elements) | Additional elements for resource naming (e.g., OS for disks) | `string` | `"OS"` | no |
| <a name="input_active_directory_domain"></a> [active\_directory\_domain](#input\_active\_directory\_domain) | Active Directory domain to join | `string` | `"ad.allwyn.co.uk"` | no |
| <a name="input_active_directory_password"></a> [active\_directory\_password](#input\_active\_directory\_password) | n/a | `any` | n/a | yes |
| <a name="input_active_directory_username"></a> [active\_directory\_username](#input\_active\_directory\_username) | n/a | `any` | n/a | yes |
| <a name="input_custom_data"></a> [custom\_data](#input\_custom\_data) | Specifies custom data to supply to the machine. On Linux-based systems, this can be used as a cloud-init script. | `string` | `"apt_upgrade: true"` | no |
| <a name="input_delete_disks_on_termination"></a> [delete\_disks\_on\_termination](#input\_delete\_disks_on_termination) | Delete all disks on when virtual machine is deleted | `bool` | `false` | no |
| <a name="input_localadmin"></a> [localadmin](#input\_localadmin) | Specifies the name of the local administrator account. | `string` | `"linuxadmin"` | no |
| <a name="input_location"></a> [location](#input\_location) | the location for the deployment | `string` | n/a | yes |
| <a name="input_ou_path"></a> [ou\_path](#input\_ou\_path) | n/a | `any` | `null` | no |
| <a name="input_rgname"></a> [rgname](#input\_rgname) | the name of the resource group for the server | `string` | n/a | yes |
| <a name="input_server_count"></a> [server\_count](#input\_server\_count) | Server count to create multiple servers | `number` | n/a | yes |
| <a name="input_size"></a> [size](#input\_size) | Specifies the size of the Virtual Machine. | `string` | `"Standard_B2ms"` | no |
| <a name="input_subnetid"></a> [subnetid](#input\_subnetid) | the subnet ID the network card attaches to | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the Virtual Machine. | `map(string)` | <pre>{<br>  "environment": "development"<br>}</pre> | no |
| <a name="input_vm_image"></a> [vm\_image](#input\_vm_image) | n/a | `map(any)` | <pre>{<br>  "offer": "WindowsServer",<br>  "publisher": "MicrosoftWindowsServer",<br>  "sku": "2022-datacenter",<br>  "version": "latest"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_random-password"></a> [random-password](#output\_random-password) | The random password generated for the admin user |

## Resource Naming

This module follows these naming conventions:

- VM name: `VM-<APPCODE>-<REGION>-<ENVIRONMENT>-<INSTANCE>` (example: VM-LSH-UKS-PRD-01)
- NIC name: `NIC-<SUBNAME>-vm-<purpose>-<environment>-<INSTANCE>` (example: NIC-auk-vm-web-prd-01)
- Disk name: `DSK-<REGION>-<APPCODE>-<ENVIRONMENT>-<DISKTYPE>-<INSTANCE>` (example: DSK-UKS-LSH-PRD-OS-01)
