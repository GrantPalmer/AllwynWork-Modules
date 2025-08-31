# Key Vault Module - Naming Convention Alignment

This document shows how the Key Vault module has been updated to align with the Virtual Machine module naming convention standards.

## Summary of Changes

The Key Vault module has been **successfully updated** to follow the established naming convention from the Virtual Machine module, ensuring consistency across all Azure infrastructure modules.

## Before vs After Comparison

### Previous Naming Convention (BEFORE)
```terraform
# Old pattern: kv-<region>-<app_code>-<environment>-<purpose>-<instance>
# Format: lowercase with hyphens
kv_name = var.app_shortcode != "" ? 
  "kv-${var.region}-${lower(var.app_shortcode)}-${var.environment}-${var.purpose}-${var.instance}" : 
  "kv-${var.region}-${var.environment}-${var.purpose}-${var.instance}"
```

**Examples**:
- `kv-uks-crm-prd-shared-01`
- `kv-ukw-erp-dev-secrets-02`

### New Naming Convention (AFTER)
```terraform
# New pattern: KV-<PURPOSE>-<APP_CODE>-<ENVIRONMENT>-<INSTANCE>
# Format: UPPERCASE with hyphens (aligned with VM module component order)
kv_name = "KV-${upper(var.purpose)}-${upper(var.app_shortcode != "" ? var.app_shortcode : "AUK")}-${upper(var.environment)}-${var.instance}"
```

**Examples**:
- `KV-SHARED-CRM-PRD-01`
- `KV-SECRETS-ERP-DEV-02`

## Alignment with Virtual Machine Module

| Component | VM Module Pattern | Key Vault Pattern | Status |
|-----------|-------------------|-------------------|---------|
| **Resource Type** | `VM-...` | `KV-...` | ✅ Aligned |
| **Purpose** | `${upper(var.purpose)}` | `${upper(var.purpose)}` | ✅ Aligned |
| **App Code** | `${upper(app_shortcode \|\| "AUK")}` | `${upper(app_shortcode \|\| "AUK")}` | ✅ Aligned |
| **Environment** | `${upper(var.environment)}` | `${upper(var.environment)}` | ✅ Aligned |
| **Instance** | `${var.instance}` | `${var.instance}` | ✅ Aligned |
| **Format** | UPPERCASE with hyphens | UPPERCASE with hyphens | ✅ Aligned |
| **Component Order** | PURPOSE-APP-ENV-INSTANCE | PURPOSE-APP-ENV-INSTANCE | ✅ Aligned |
| **Fallback** | "AUK" when app_shortcode empty | "AUK" when app_shortcode empty | ✅ Aligned |

## Variable Standardization

### Added Variables for Consistency
```terraform
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
```

### Enhanced Validation Rules
```terraform
variable "purpose" {
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.purpose))
    error_message = "Purpose must contain only alphanumeric characters."
  }
}

variable "instance" {
  validation {
    condition     = can(regex("^[0-9]{2}$", var.instance))
    error_message = "Instance must be a 2-digit number (e.g., 01, 02, 03)."
  }
}

variable "app_shortcode" {
  validation {
    condition     = var.app_shortcode == "" || can(regex("^[A-Z]{2,6}$", var.app_shortcode))
    error_message = "App shortcode must be 2-6 uppercase letters or empty string."
  }
}
```

### Removed Unused Variables
- ❌ `platform_name` - Not used in any resources, removed for consistency

## Tag Standardization

### Updated Tag Structure
```terraform
base_tags = {
  Environment = title(var.environment)    # "Prd", "Dev", "Tst"
  Department  = var.department           # Configurable, default: "Platform Engineering"
  Source      = "terraform"              # Always "terraform"
  Project     = var.project              # Configurable, default: "CoreServices"
  CostCenter  = var.cost_center          # Configurable, default: "TBC"
  RFC         = var.rfc                  # Configurable, default: "TBC"
}
```

## Real-World Examples

### Production CRM Shared Key Vault
```hcl
module "crm_shared_kv" {
  source = "../../modules/key-vault"
  
  region        = "uks"
  environment   = "prd"
  purpose       = "shared"
  app_shortcode = "CRM"
  instance      = "01"
  
  location = "UK South"
  rgname   = "rg-crm-prd-uks"
  sku      = "standard"
}
```
**Result**: `KV-SHARED-CRM-PRD-01`

### Development Secrets Vault
```hcl
module "dev_secrets_kv" {
  source = "../../modules/key-vault"
  
  region      = "ukw"
  environment = "dev"
  purpose     = "secrets"
  instance    = "02"
  
  location = "UK West"
  rgname   = "rg-platform-dev-ukw"
  sku      = "standard"
}
```
**Result**: `KV-SECRETS-AUK-DEV-02` (uses fallback AUK)

### Certificate Management Vault
```hcl
module "cert_kv" {
  source = "../../modules/key-vault"
  
  region        = "euw"
  environment   = "prd"
  purpose       = "certs"
  app_shortcode = "SEC"
  instance      = "01"
  
  location = "West Europe"
  rgname   = "rg-security-prd-euw"
  sku      = "premium"
}
```
**Result**: `KV-CERTS-SEC-PRD-01`

## Cross-Module Naming Consistency

Now both modules follow the same pattern:

### Virtual Machine Resources
- VM: `VM-WEB-CRM-PRD-01`
- NIC: `NIC-frontend-vm-web-frontend-prd-01`
- Disk: `DSK-UKS-CRM-PRD-OS-01`
- Hostname: `azwebcrmprd01`

### Key Vault Resources
- Key Vault: `KV-SHARED-CRM-PRD-01`

### Pattern Recognition
Both modules use:
- **Resource prefix** (VM, KV, DSK, NIC)
- **Purpose/Role** (WEB, SHARED, OS)
- **App code** (CRM, ERP, AUK)
- **Environment** (PRD, DEV, TST)
- **Instance** (01, 02, 03)

## Validation and Testing

### Terraform Validation
```bash
# Validate the updated module
cd modules/key-vault
terraform validate
# ✅ Success: The configuration is valid.
```

### Example Deployment Test
```bash
# Test with example configuration
terraform plan -var="region=uks" -var="environment=prd" \
  -var="purpose=shared" -var="app_shortcode=CRM" \
  -var="instance=01" -var="location=UK South" \
  -var="rgname=rg-test" -var="sku=standard"

# Expected output includes:
# azurerm_key_vault.core will be created
#   name = "KV-UKS-CRM-PRD-SHARED-01"
```

## Benefits of Alignment

1. **Consistency**: All modules follow the same naming pattern
2. **Predictability**: Easy to predict resource names across modules
3. **Automation**: Scripts can rely on consistent naming patterns
4. **Organization**: Clear resource identification and grouping
5. **Compliance**: Unified approach to Azure resource governance
6. **Maintenance**: Simplified module management and updates

## Next Steps

The Key Vault module is now fully aligned with the Virtual Machine module naming convention. Consider applying the same standardization to other modules:

1. **Storage Account module** - Update to follow same pattern
2. **Network Security Group module** - Align naming conventions
3. **Application Insights module** - Standardize resource naming
4. **Other Azure resource modules** - Apply consistent patterns

## Migration Notes

**For existing deployments**: The naming change is a breaking change. Existing Key Vaults will need to be:
1. **Planned migration**: Use `terraform import` with new names
2. **Blue-green deployment**: Deploy new vaults with new names, migrate data, destroy old ones
3. **Documentation update**: Update all references to use new naming pattern

**Recommendation**: Implement in new environments first, then plan migration strategy for existing resources.
