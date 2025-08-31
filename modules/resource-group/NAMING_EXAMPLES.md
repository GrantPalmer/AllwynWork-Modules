# Resource Group Naming Convention Examples

This document provides examples of how the new standardized naming convention works.

## Pattern: `rg-{purpose}-{app_shortcode}-{environment}-{instance}`

### Example 1: Security Event Hub Production
**Input:**
```hcl
subscription_name = "AUK-Security-Production-001"
app_shortcode = "evh"
environment = "prd"
instance = "01"
```
**Output:** `rg-security-evh-prd-01`

### Example 2: Sandbox Development
**Input:**
```hcl
subscription_name = "AUK-Sandbox-Development-002"
app_shortcode = "sbx"
environment = "dev"
instance = "01"
```
**Output:** `rg-sandbox-sbx-dev-01`

### Example 3: Platform Test
**Input:**
```hcl
subscription_name = "AUK-Platform-Test-001"
app_shortcode = "plt"
environment = "tst"
instance = "02"
```
**Output:** `rg-platform-plt-tst-02`

### Example 4: Analytics Production
**Input:**
```hcl
subscription_name = "AUK-Analytics-Production-001"
app_shortcode = "ana"
environment = "prd"
instance = "01"
```
**Output:** `rg-analytics-ana-prd-01`

## Purpose Component Extraction

The module automatically extracts the purpose from the subscription name:

| Subscription Name | Extracted Purpose |
|-------------------|-------------------|
| `AUK-Security-Production-001` | `security` |
| `AUK-Sandbox-Development-002` | `sandbox` |
| `AUK-Platform-Test-001` | `platform` |
| `AUK-Analytics-Production-001` | `analytics` |
| `AUK-EventHub-Staging-003` | `eventhub` |
| `AUK-DataLake-UAT-001` | `datalake` |

## App Short Codes

Common application short codes used in the organization:

| Application | Short Code |
|-------------|------------|
| Event Hub | `evh` |
| Sandbox | `sbx` |
| Security | `sec` |
| Platform | `plt` |
| Analytics | `ana` |
| Data Lake | `dlk` |
| API Gateway | `apg` |
| Web Application | `web` |
| Database | `db` |
| Storage | `stg` |

## Environment Codes

| Environment | Code |
|-------------|------|
| Production | `prd` |
| Development | `dev` |
| Test | `tst` |
| Staging | `stg` |
| UAT | `uat` |

## Complete Usage Example

```hcl
module "security_eventhub_rg" {
  source = "git::https://github.com/Allwyn-UK/plat-tf-az-modules.git//modules/resource-group"
  
  # Subscription information
  subscription_name = "AUK-Security-Production-001"
  
  # Resource configuration
  app_shortcode = "evh"
  environment   = "prd"
  instance      = "01"
  location      = "UK South"
  
  # Additional tags
  tags = {
    Owner       = "Security Team"
    Project     = "Event Hub Implementation"
    CostCenter  = "SECURITY-001"
  }
}

# Output: rg-security-evh-prd-01
output "resource_group_name" {
  value = module.security_eventhub_rg.resource_group_name
}
```

## Benefits of the New Convention

1. **Shorter Names**: More concise than legacy pattern
2. **Clear Purpose**: Easy to identify the workload type
3. **Consistent Structure**: Same pattern across all resources
4. **Automated Parsing**: No manual purpose definition needed
5. **Environment Clarity**: Clear environment identification
6. **Scalability**: Easy to add multiple instances

## Migration Guide

### From Legacy Pattern
**Old:** `uks-prd-platform-security-evh-rg-01`
**New:** `rg-security-evh-prd-01`

### Migration Steps
1. Update module calls to include `subscription_name`
2. Remove legacy variables (`region`, `platform_name`, `purpose`)
3. Verify generated names match expectations
4. Plan and apply changes during maintenance window

## Validation

The module includes validation for:
- **Environment**: Must be one of `prd`, `dev`, `tst`, `stg`, `uat`
- **App Shortcode**: Should be 2-4 characters
- **Instance**: 2-digit format recommended
- **Subscription Name**: Must follow `{ORG}-{PURPOSE}-{ENV}-{NUMBER}` pattern
