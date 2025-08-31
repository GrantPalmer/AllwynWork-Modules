# Azure Windows VM Domain Join Terraform Module

This Terraform module creates Windows Virtual Machines in Azure and automatically joins them to an Active Directory domain. The module follows enterprise naming conventions and provides flexible tagging capabilities.

## Features

- ✅ **Automated Domain Join**: Automatically joins VMs to specified AD domain
- ✅ **Enterprise Naming**: Follows standardized naming conventions for all resources
- ✅ **Flexible Tagging**: Configurable tags with automatic timestamp generation
- ✅ **Multiple VM Support**: Deploy multiple VMs with consistent configuration
- ✅ **Custom Hostnames**: Generates compliant computer names following Azure conventions
- ✅ **UK Defaults**: Configured with UK South region and GMT timezone by default

## Resource Naming Conventions

The module follows these naming patterns:

| Resource Type | Pattern | Example |
|---------------|---------|---------|
| Virtual Machine | `VM-<PURPOSE>-<APP_CODE>-<ENVIRONMENT>-<INSTANCE>` | `VM-WEB-APP-PRD-01` |
| Computer Name | `az<purpose><app_code><environment><instance>` | `azwebappprd01` |
| Network Interface | `NIC-<subname>-vm-<purpose>-<subname>-<environment>-<INSTANCE>` | `NIC-frontend-vm-web-frontend-prd-01` |
| OS Disk | `DSK-<REGION>-<APP_CODE>-<ENVIRONMENT>-<DISK_TYPE>-<INSTANCE>` | `DSK-UKS-APP-PRD-OS-01` |

## Usage

### Basic Example

```hcl
module "windows_vm" {
  source = "path/to/this/module"

  # Required variables
  rgname       = "rg-uks-myapp-prd-01"
  location     = "UK South"
  subnetid     = "/subscriptions/.../subnets/subnet-01"
  server_count = 2

  # Naming variables
  platform_name = "myapp"
  resource_type = "vm"
  # region        = "uks"     # Optional - defaults to "uks"
  # environment   = "prd"     # Optional - defaults to "prd"
  purpose       = "web"
  app_shortcode = "myapp"

  # Domain join configuration
  active_directory_domain   = "company.local"
  active_directory_username = var.domain_admin_username
  active_directory_password = var.domain_admin_password

  # Optional: Custom tags
  tags = {
    Owner = "team@company.com"
    Criticality = "High"
  }
}
```

### Advanced Example with Custom Configuration

```hcl
module "windows_vm_advanced" {
  source = "path/to/this/module"

  # VM Configuration
  rgname       = "rg-uks-webapp-prd-01"
  location     = "UK South"
  subnetid     = "/subscriptions/.../subnets/web-subnet"
  server_count = 3
  size         = "Standard_D4s_v3"

  # Naming Configuration
  platform_name       = "webapp"
  resource_type        = "vm"
  # region              = "uks"     # Optional - defaults to "uks"
  # environment         = "prd"     # Optional - defaults to "prd"
  purpose             = "api"
  app_shortcode       = "webapp"
  subname            = "backend"
  additional_elements = "os"

  # Domain Join Configuration
  active_directory_domain   = "internal.company.com"
  active_directory_username = var.domain_admin_username
  active_directory_password = var.domain_admin_password
  ou_path                  = "OU=WebServers,OU=Production,DC=internal,DC=company,DC=com"

  # Enhanced Tagging
  department            = "Engineering"
  project              = "CustomerPortal"
  cost_center          = "CC-12345"
  rfc                 = "RFC-2024-001"
  stop_start_schedule  = "Weekdays=07:00-19:00"
  update_ring         = "Standard"
  enable_timestamp_tags = true
  expiry_hours        = 8760  # 1 year

  # Custom Tags
  tags = {
    Owner           = "webapp-team@company.com"
    Application     = "CustomerPortal"
    Criticality     = "High"
    BackupSchedule  = "Daily"
    MonitoringGroup = "WebServices"
  }
}
```

## Input Variables

### Required Variables

| Name | Type | Description |
|------|------|-------------|
| `rgname` | string | Resource group name |
| `location` | string | Azure region for deployment |
| `subnetid` | string | Subnet ID where VMs will be deployed |
| `server_count` | number | Number of VMs to create |
| `platform_name` | string | Platform name for the workload |
| `resource_type` | string | Resource type identifier |
| `active_directory_username` | string | Domain admin username |
| `active_directory_password` | string | Domain admin password |
| `subscription_id` | string | Azure subscription ID (optional) |

### Naming Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `region` | string | `"uks"` | Region code (uks, ukw, euw, etc.) |
| `environment` | string | `"prd"` | Environment (prd, dev, tst, stg, uat) |
| `purpose` | string | - | Purpose of the VM (web, app, db, etc.) |
| `app_shortcode` | string | `""` | Application short code |
| `subname` | string | `""` | Subname for additional identification |
| `additional_elements` | string | `"OS"` | Additional elements for disk naming |

### VM Configuration Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `size` | string | `"Standard_B2ms"` | VM size |
| `active_directory_domain` | string | `"ad.allwyn.co.uk"` | AD domain to join |
| `ou_path` | string | `null` | Optional OU path for domain join |

### Tagging Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `tags` | map(string) | `{}` | Custom tags to apply |
| `enable_timestamp_tags` | bool | `true` | Enable automatic timestamp tags |
| `expiry_hours` | number | `26280` | Hours until expiry (default: 3 years) |
| `department` | string | `"Platform Engineering"` | Department name |
| `project` | string | `"CoreServices"` | Project name |
| `cost_center` | string | `"TBC"` | Cost center code |
| `rfc` | string | `"TBC"` | RFC number |
| `stop_start_schedule` | string | `"Weekdays=08:00-18:00 / Weekends=0"` | VM schedule (AutoSchedule tag) |
| `update_ring` | string | `"Priority"` | Update ring (Priority/Standard/Extended) |

## Outputs

| Name | Description |
|------|-------------|
| `admin_password` | Auto-generated admin password (sensitive) |
| `vm_names` | Names of created VMs |
| `vm_hostnames` | Computer names of VMs |
| `vm_ids` | VM resource IDs |
| `nic_names` | Network interface names |
| `nic_ids` | Network interface IDs |
| `private_ip_addresses` | Private IP addresses |
| `applied_tags` | Final set of applied tags |

## Tags Applied

The module automatically applies these tags to all resources:

### Base Tags (Applied to ALL Resources)
- `Environment`: Derived from environment variable (title case)
- `Department`: Department name (default: "Platform Engineering")
- `Source`: Always "terraform"
- `Project`: Configurable project name
- `CostCenter`: Cost center for billing
- `RFC`: RFC number for the deployment
- `UpdateRing`: Update priority ring

### Timestamp Tags (Optional - Applied to ALL Resources)
- `CreatedDate`: Resource creation date (DD-MM-YYYY format)
- `ExpiryDate`: Resource expiry date (DD-MM-YYYY format)

### VM-Specific Additional Tags
- `AutoSchedule`: VM start/stop schedule (ONLY applied to Virtual Machines)

### Custom Tags
Any additional tags provided via the `tags` variable will be merged with base tags. Custom tags take precedence over base tags if there are conflicts.

## Tag Examples

### All Resources (NICs, etc.) will have these tags:
```hcl
{
  Environment  = "Prd"                    # From var.environment (default: "prd")
  Department   = "Platform Engineering"   # From var.department (default)
  Source      = "terraform"              # Always applied
  Project     = "CoreServices"           # From var.project (default)
  CostCenter  = "TBC"                    # From var.cost_center (default)
  RFC         = "TBC"                    # From var.rfc (default)
  UpdateRing  = "Priority"               # From var.update_ring (default)
  CreatedDate = "14-08-2025"             # Auto-generated (if enabled)
  ExpiryDate  = "14-08-2025"             # Auto-generated (if enabled)
  # + any custom tags from var.tags
}
```

### Virtual Machines will have ALL the above tags PLUS:
```hcl
{
  # All the base tags above, PLUS:
  AutoSchedule = "Weekdays=08:00-18:00 / Weekends=0"  # VM-specific scheduling
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| azurerm | ~> 4.0 |
| random | ~> 3.6 |

## Authentication

This module requires Azure authentication. Choose one of the following methods:

### Method 1: Azure CLI (Recommended for development)
```bash
# Login to Azure
az login

# Set your default subscription
az account set --subscription "your-subscription-id"

# Verify your current subscription
az account show
```

### Method 2: Environment Variables
```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_TENANT_ID="your-tenant-id"
```

### Method 3: Specify Subscription in Module
```hcl
module "windows_vm" {
  source = "path/to/this/module"
  
  subscription_id = "your-subscription-id"
  # ... other variables
}
```

### Method 4: Managed Identity (Azure resources)
No additional configuration needed when running from Azure resources with managed identity enabled.

## Troubleshooting Authentication

**Error: "subscription ID could not be determined"**
- Ensure you're logged in: `az login`
- Set default subscription: `az account set --subscription <id>`
- Or specify `subscription_id` in the module call
- Or set `ARM_SUBSCRIPTION_ID` environment variable

## Examples

See the `examples/` directory for complete working examples:
- `examples/basic/` - Basic deployment example
- `examples/advanced/` - Advanced configuration with custom tags

## Contributing

1. Follow the established naming conventions
2. Update documentation for any new variables
3. Add examples for new features
4. Ensure all resources are properly tagged

## License

This module is maintained by Allwyn UK Limited.
