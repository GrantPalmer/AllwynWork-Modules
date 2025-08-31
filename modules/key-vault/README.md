# Terraform Azure Key Vault Module

This module creates an Azure Key Vault with standardized naming conventions, security configurations, and access policies.

## Features

- Creates Azure Key Vault with configurable settings
- **Standardized naming conventions** aligned with virtual-machine module standards
- Comprehensive tagging strategy with automatic timestamps
- Network access controls and IP restrictions
- Dynamic access policy configuration
- Purge protection and soft delete capabilities
- Integration with Azure services (disk encryption, deployment, templates)

## Naming Convention

The module follows the established naming convention pattern:

**Pattern**: `KV-<PURPOSE>-<APP_CODE>-<ENVIRONMENT>-<INSTANCE>`

**Format**: All UPPERCASE with hyphens

**Examples**:
- `KV-SHARED-CRM-PRD-01` - Production CRM shared Key Vault #1
- `KV-SECRETS-ERP-DEV-02` - Development ERP secrets Key Vault #2
- `KV-CERTS-AUK-TST-01` - Test certificate Key Vault #1

## Usage

```hcl
module "key_vault" {
  source = "../../modules/key-vault"

  # Required variables
  region       = "uks"
  environment  = "prd" 
  purpose      = "shared"
  location     = "UK South"
  rgname       = "rg-example"
  sku          = "standard"

  # Optional configurations
  app_shortcode = "CRM"
  instance     = "01"
  
  # Tagging variables (with defaults)
  department   = "Platform Engineering"
  project      = "CoreServices"
  cost_center  = "TBC"
  rfc          = "TBC"
  
  # Access policies
  kv_access_policies = [
    {
      tenant_id = "your-tenant-id"
      object_id = "your-object-id"
      key_permissions = ["Get", "List"]
      secret_permissions = ["Get", "List", "Set"]
      storage_permissions = []
      certificate_permissions = ["Get", "List"]
    }
  ]

  # Network restrictions
  key_vault_allowed_ips = ["1.2.3.4"]
  virtual_network_subnet_ids = ["/subscriptions/.../subnets/subnet1"]
  
  tags = {
    Application = "MyApp"
    Owner       = "TeamName"
  }
}
```

**Result**: `KV-SHARED-CRM-PRD-01`

### Development Environment Key Vault
```hcl
module "dev_key_vault" {
  source = "../../modules/key-vault"

  region        = "ukw"
  environment   = "dev"
  purpose       = "secrets"
  app_shortcode = "ERP"
  instance      = "02"
  
  location = "UK West"
  rgname   = "rg-erp-dev-ukw"
  sku      = "standard"
  
  kv_access_policies = [
    {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = data.azurerm_client_config.current.object_id
      
      key_permissions = ["Get", "List", "Create", "Delete"]
      secret_permissions = ["Get", "List", "Set", "Delete"]
      storage_permissions = []
      certificate_permissions = ["Get", "List", "Create"]
    }
  ]
}
```

**Result**: `KV-SECRETS-ERP-DEV-02`

### Certificate Management Key Vault
```hcl
module "cert_key_vault" {
  source = "../../modules/key-vault"

  region      = "euw"
  environment = "prd"
  purpose     = "certs"
  instance    = "01"
  
  location = "West Europe"
  rgname   = "rg-security-prd-euw"
  sku      = "premium"  # Premium for HSM support
  
  # Enhanced security settings
  purge_protection_enabled = true
  
  # Network restrictions
  default_network_acl_action = "Deny"
  key_vault_allowed_ips = ["10.0.0.0/16"]
  
  kv_access_policies = [
    {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = var.certificate_admin_object_id
      
      key_permissions = []
      secret_permissions = []
      storage_permissions = []
      certificate_permissions = [
        "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", 
        "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", 
        "Purge", "Recover", "Restore", "SetIssuers", "Update"
      ]
    }
  ]
}
```

**Result**: `KV-CERTS-AUK-PRD-01` (uses default AUK when app_shortcode is empty)
```

## Variables

| Name | Description | Type | Default | Required | Validation |
|------|-------------|------|---------|:--------:|------------|
| `region` | Azure region abbreviation | `string` | n/a | yes | Must be one of: uks, ukw, euw, neu, use, usw |
| `environment` | Environment designation | `string` | n/a | yes | Must be one of: prd, dev, tst, stg, uat |
| `purpose` | Purpose/workload name | `string` | n/a | yes | Alphanumeric characters only |
| `location` | Azure region for resource deployment | `string` | n/a | yes | - |
| `rgname` | Resource group name for the Key Vault | `string` | n/a | yes | - |
| `sku` | Key Vault SKU (standard/premium) | `string` | n/a | yes | - |
| `app_shortcode` | Application short code | `string` | `""` | no | 2-6 uppercase letters or empty |
| `instance` | Instance number | `string` | `"01"` | no | 2-digit number (01, 02, etc.) |
| `department` | Department responsible for resource | `string` | `"Platform Engineering"` | no | - |
| `project` | Project name | `string` | `"CoreServices"` | no | - |
| `cost_center` | Cost center for billing | `string` | `"TBC"` | no | - |
| `rfc` | RFC number for change tracking | `string` | `"TBC"` | no | - |
| `expiry_hours` | Hours from creation until expiry for ExpiryDate tag | `number` | `26280` | no | 3 years (24*365*3) |
| `update_ring` | Update ring priority | `string` | `"Priority"` | no | Must be one of: Priority, Standard, Extended |
| `kv_access_policies` | Access policy configurations | `any` | n/a | yes | See access policy structure |
| `purge_protection_enabled` | Enable purge protection | `bool` | `true` | no | - |
| `default_network_acl_action` | Default network ACL action | `string` | `"Deny"` | no | - |
| `key_vault_allowed_ips` | List of allowed IP addresses | `list(string)` | `null` | no | - |
| `virtual_network_subnet_ids` | Allowed subnet IDs | `list(string)` | `null` | no | - |
| `tags` | Additional resource tags | `map(string)` | `{"environment": "development"}` | no | - |

## Outputs

| Name | Description |
|------|-------------|
| `id` | ID of the created Key Vault |
| `vault_uri` | URI of the Key Vault |
| `name` | Name of the created Key Vault |
| `resource_group_name` | Resource group name containing the Key Vault |
| `location` | Location where the Key Vault is deployed |
| `applied_tags` | Final set of tags applied to the Key Vault |

## Access Policy Structure

```hcl
kv_access_policies = [
  {
    tenant_id = "12345678-1234-1234-1234-123456789012"
    object_id = "87654321-4321-4321-4321-210987654321"
    
    key_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Import", 
      "Backup", "Restore", "Recover", "Purge"
    ]
    
    secret_permissions = [
      "Get", "List", "Set", "Delete", "Backup", "Restore", 
      "Recover", "Purge"
    ]
    
    storage_permissions = [
      "Get", "List", "Set", "Delete", "Backup", "Restore", 
      "Recover", "Purge"
    ]
    
    certificate_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Import",
      "Backup", "Restore", "Recover", "Purge", "ManageContacts",
      "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers",
      "DeleteIssuers"
    ]
  }
]
```

## Naming Convention Details

This module follows the standardized naming convention established across all Azure modules:

### Pattern
- **Format**: `KV-<PURPOSE>-<APP_CODE>-<ENVIRONMENT>-<INSTANCE>`
- **Case**: All UPPERCASE with hyphens as separators
- **Fallback**: When `app_shortcode` is empty, defaults to "AUK"

### Component Examples
- **Purpose**: SHARED, SECRETS, CERTS, CONFIG
- **App Code**: CRM, ERP, LSH, AUK (fallback)
- **Environment**: PRD, DEV, TST, STG, UAT
- **Instance**: 01, 02, 03, etc.

### Real Examples
- `KV-SHARED-CRM-PRD-01` - Production CRM shared secrets
- `KV-CONFIG-ERP-DEV-02` - Development ERP configuration vault
- `KV-CERTS-AUK-PRD-01` - Production certificate management vault

## Resource Tags

The module automatically applies comprehensive tags:

### Standard Tags (Always Applied)
```hcl
{
  Environment = "Prd"              # Title case environment
  Department  = "Platform Engineering"  # Configurable
  Source      = "terraform"       # Always terraform
  Project     = "CoreServices"    # Configurable
  CostCenter  = "TBC"            # Configurable
  RFC         = "TBC"            # Configurable
  UpdateRing  = "Priority"       # Configurable (Priority/Standard/Extended)
}
```

### Timestamp Tags (Automatic)
```hcl
{
  CreatedDate = "26-08-2025"      # Creation date
  ExpiryDate  = "26-08-2028"      # 3 years from creation
}
```

### Custom Tags (User-Provided)
```hcl
tags = {
  Application = "MyApp"
  Owner       = "TeamName"
  Backup      = "Required"
}
```

## Security Features

- **Purge Protection**: Enabled by default (configurable)
- **Soft Delete**: 7-day retention period
- **Network ACLs**: Default deny with configurable exceptions
- **Azure Service Integration**: Enabled for disk encryption and template deployment
- **IP Restrictions**: Configurable allowed IP ranges
- **Subnet Access**: Configurable virtual network subnet access

## Compliance and Best Practices

This Key Vault module ensures:
- ✅ **Consistent naming** across all environments
- ✅ **Comprehensive tagging** for cost tracking and governance
- ✅ **Security by default** with restrictive network ACLs
- ✅ **Audit trails** with RFC and change tracking tags
- ✅ **Integration ready** for Azure services and deployment automation
- ✅ **Scalable architecture** with predictable instance numbering
