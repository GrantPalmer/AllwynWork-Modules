# Virtual Machine Module Enhancement Summary

This document summarizes the comprehensive enhancements made to the virtual machine module to integrate advanced security, monitoring, and management capabilities.

## Key Enhancements Made

### 1. Enhanced Security Features
- **Encryption at Host**: Added `enable_encryption_at_host` variable to enable host-level encryption
- **Patch Management**: Configurable automatic patch management with `enable_patch_management`
- **Boot Diagnostics**: Configurable boot diagnostics with `enable_boot_diagnostics`
- **Storage Options**: Configurable OS disk storage account types (Standard_LRS, StandardSSD_LRS, Premium_LRS)

### 2. Advanced Monitoring & Management
- **Azure Monitor Agent**: Installable via `enable_azure_monitor` variable
- **Dependency Agent**: For application dependency mapping via `enable_dependency_agent`
- **Guest Configuration**: Azure Policy enforcement via `enable_guest_configuration`
- **Data Collection Rules**: Automatic association with DCRs for log collection

### 3. Localization & Regional Settings
- **UK Locale Setting**: Automatic configuration of UK regional settings via `enable_locale_setting`
- **Timezone Configuration**: Set to GMT Standard Time by default

### 4. Improved Password Management
- **Per-VM Passwords**: Each VM now gets a unique random password
- **Enhanced Password Complexity**: Improved character set for stronger passwords
- **Configurable Admin Username**: Customizable admin username via `admin_username` variable

### 5. Enhanced Network Interface Configuration
- **Lifecycle Management**: Added lifecycle rules to ignore IP configuration changes
- **Improved Tagging**: Consistent tagging across all resources

### 6. Extension Management
All VM extensions are now configurable and include:
- Domain Join (mandatory)
- Guest Configuration/Azure Policy
- Dependency Agent
- Azure Monitor Agent
- UK Locale Configuration

### 7. Improved Resource Lifecycle
- **Enhanced Lifecycle Rules**: Better handling of tag changes and identity modifications
- **Conditional Resource Creation**: Extensions only created when enabled
- **Dependency Management**: Proper dependency ordering for extensions

## New Variables Added

### Security & Configuration
- `enable_encryption_at_host` (bool): Enable encryption at host level
- `enable_patch_management` (bool): Enable automatic patch management
- `enable_boot_diagnostics` (bool): Enable boot diagnostics
- `admin_username` (string): Configurable admin username
- `os_disk_storage_account_type` (string): OS disk storage type

### Monitoring & Management
- `enable_azure_monitor` (bool): Install Azure Monitor Agent
- `enable_dependency_agent` (bool): Install Dependency Agent
- `enable_guest_configuration` (bool): Install Guest Configuration extension
- `data_collection_rule_id` (string): DCR ID for log collection association

### Localization
- `enable_locale_setting` (bool): Configure UK locale settings

## Updated Outputs

### Enhanced Password Management
- `admin_passwords` (list): Individual passwords for each VM (replaces single password)
- `admin_username` (string): The configured admin username

### Extension Status
- `extensions_installed` (object): Shows which extensions are installed
- `dcr_associations` (list): Data Collection Rule association names

## Migration Notes

### Breaking Changes
1. **Password Output**: `admin_password` (single) → `admin_passwords` (list)
2. **Admin Username**: Now configurable via `admin_username` variable (default: "brc-adminuser")

### Backward Compatibility
- All new features are optional with sensible defaults
- Existing configurations will continue to work
- New variables have appropriate default values

## Usage Examples

### Minimal Configuration (Backward Compatible)
```hcl
module "vm" {
  source = "../../modules/virtual-machine"
  
  region       = "uks"
  environment  = "dev"
  purpose      = "web"
  rgname       = "rg-example"
  location     = "UK South"
  subnetid     = var.subnet_id
  server_count = 1
  
  active_directory_domain    = "ad.allwyn.co.uk"
  active_directory_username  = var.ad_user
  active_directory_password  = var.ad_pass
}
```

### Full Feature Configuration
```hcl
module "vm_advanced" {
  source = "../../modules/virtual-machine"
  
  # Basic config...
  
  # Enhanced security
  enable_encryption_at_host     = true
  enable_patch_management       = true
  os_disk_storage_account_type  = "Premium_LRS"
  
  # Full monitoring
  enable_azure_monitor         = true
  enable_dependency_agent      = true
  enable_guest_configuration   = true
  data_collection_rule_id      = var.dcr_id
  
  # Locale configuration
  enable_locale_setting        = true
}
```

## Implementation Details

### Resource Naming
All resources follow the established naming conventions:
- VMs: `VM-{PURPOSE}-{APP_CODE}-{ENVIRONMENT}-{INSTANCE}`
- NICs: `NIC-{subname}-vm-{purpose}-{subname}-{environment}-{instance}`
- Disks: `DSK-{REGION}-{APP_CODE}-{ENVIRONMENT}-{DISK_TYPE}-{INSTANCE}`

### Extension Dependencies
Extensions are installed in the correct order:
1. Domain Join (required)
2. All other extensions (parallel, dependent on domain join)

### Conditional Resource Creation
All new features use conditional resource creation patterns:
```hcl
resource "azurerm_virtual_machine_extension" "example" {
  count = var.enable_feature ? var.server_count : 0
  # ... configuration
}
```

This ensures resources are only created when needed, optimizing deployment time and costs.
