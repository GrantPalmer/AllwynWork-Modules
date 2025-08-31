# Azure Resource Group Terraform Module

This module creates an Azure Resource Group with standardized naming conventions and tagging.

## Naming Convention

The module supports two naming patterns:

### **New Standard Pattern (Recommended)**
```
rg-{purpose}-{app_shortcode}-{environment}-{instance}
```

**Example:** `rg-security-evh-prd-01`

Where:
- `rg` = Resource type prefix
- `security` = Purpose extracted from subscription name (4th component of `sub_auk_platform_security`)
- `evh` = Application short code
- `prd` = Environment
- `01` = Instance number

### **Subscription Name Format**
The module expects subscription names in the format:
```
sub_auk_platform_{purpose}
```

Examples:
- `sub_auk_platform_security` → purpose = "security"
- `sub_auk_platform_eventhub` → purpose = "eventhub"
- `sub_auk_platform_sandbox` → purpose = "sandbox"

### **Legacy Pattern (Backward Compatibility)**
```
{region}-{environment}-{platform_name}-{purpose}-{app_shortcode}-rg-{instance}
```

## Usage Examples

### **New Standard Pattern**
```hcl
module "security_rg" {
  source = "./modules/resource-group"
  
  # New pattern variables
  subscription_name = "sub_auk_platform_security"
  app_shortcode    = "evh"
  environment      = "prd"
  instance         = "01"
  location         = "UK South"
  
  # Result: rg-security-evh-prd-01
}

module "eventhub_rg" {
  source = "./modules/resource-group"
  
  subscription_name = "sub_auk_platform_eventhub"
  app_shortcode    = "msg"
  environment      = "dev"
  instance         = "02"
  location         = "UK South"
  
  # Result: rg-eventhub-msg-dev-02
}

module "sandbox_rg" {
  source = "./modules/resource-group"
  
  subscription_name = "sub_auk_platform_sandbox"
  app_shortcode    = "sbx"
  environment      = "dev"
  instance         = "01"
  location         = "UK South"
  
  # Result: rg-sandbox-sbx-dev-01
}
```

### **User Access Management**
```hcl
module "security_rg_with_users" {
  source = "./modules/resource-group"
  
  subscription_name = "sub_auk_platform_security"
  app_shortcode    = "evh"
  environment      = "prd"
  instance         = "01"
  location         = "UK South"
  
  # Assign users to different roles
  contributor_users = [
    "john.doe@allwyn.co.uk",
    "jane.smith@allwyn.co.uk"
  ]
  
  reader_users = [
    "audit.user@allwyn.co.uk",
    "readonly.service@allwyn.co.uk"
  ]
  
  owner_users = [
    "admin.user@allwyn.co.uk"
  ]
  
  # Result: rg-security-evh-prd-01 with assigned users
}
```

### **Legacy Pattern**
```hcl
module "legacy_rg" {
  source = "./modules/resource-group"
  
  # Legacy pattern variables
  region         = "uks"
  environment    = "prd"
  platform_name  = "platform"
  purpose        = "web"
  app_shortcode  = "evh"
  instance       = "01"
  location       = "UK South"
  
  # Result: uks-prd-platform-web-evh-rg-01
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.116.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.47.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.116.0 |
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 2.47.0 |

## User Access Management

The module supports automatic assignment of Azure AD users to the resource group with different roles:

### **Supported Roles:**
- **Owner**: Full access including ability to manage access
- **Contributor**: Full access except managing access 
- **Reader**: Read-only access

### **User Assignment Variables:**
- `contributor_users`: List of UPNs for Contributor role
- `reader_users`: List of UPNs for Reader role  
- `owner_users`: List of UPNs for Owner role

### **Requirements for User Assignment:**
- Users must exist in Azure AD
- Service Principal must have `User.Read.All` API permission
- Service Principal must have sufficient RBAC permissions to assign roles

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.116.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.116.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_shortcode"></a> [app\_shortcode](#input\_app\_shortcode) | Application short code (e.g., LSH, AUK) | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The deployment environment (e.g., dev, test, prod) | `string` | n/a | yes |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance number or unique identifier | `string` | `"01"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_platform_name"></a> [platform\_name](#input\_platform\_name) | The specific work package or platform name (e.g., lss, mds) | `string` | n/a | yes |
| <a name="input_purpose"></a> [purpose](#input\_purpose) | The purpose or function of the resource (e.g., web, db, api) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Short region code where the resource resides (e.g., uks, ukw) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource group | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The ID of the created resource group |
| <a name="output_resource_group_location"></a> [resource\_group\_location](#output\_resource\_group\_location) | The location/region of the resource group |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the created resource group |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags applied to the resource group |

## Usage

### Basic Usage

```hcl
module "resource_group" {
  source = "git::https://github.com/Allwyn-UK/plat-tf-az-modules.git//modules/resource-group?ref=main"

  region        = "uks"
  environment   = "dev"
  platform_name = "lss"
  purpose       = "web"
  location      = "UK South"
}
```

### With Application Short Code

```hcl
module "resource_group" {
  source = "git::https://github.com/Allwyn-UK/plat-tf-az-modules.git//modules/resource-group?ref=main"

  region        = "uks"
  environment   = "prod"
  platform_name = "lss"
  purpose       = "api"
  app_shortcode = "LSH"
  instance      = "02"
  location      = "UK South"
  
  tags = {
    Owner       = "Platform Team"
    CostCenter  = "IT-001"
    Environment = "Production"
  }
}
```

### Naming Convention

This module follows a standardized naming pattern:

- **Without app_shortcode**: `{region}-{environment}-{platform_name}-{purpose}-rg-{instance}`
- **With app_shortcode**: `{region}-{environment}-{platform_name}-{purpose}-{app_shortcode}-rg-{instance}`

Example outputs:
- `uks-dev-lss-web-rg-01`
- `uks-prod-lss-api-LSH-rg-02`

### Default Tags

The module automatically applies the following tags:
- Environment (from variable)
- Department: "TechOps"
- Source: "terraform" 
- CreatedDate: Current date in DD-MM-YYYY format
- ExpiryDate: 3 years from creation
- Project: "CoreServices"
- CostCenter: "TBC"
- RFC: "TBC"

Additional tags can be provided via the `tags` variable and will be merged with the defaults.
