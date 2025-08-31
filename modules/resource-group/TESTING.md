# Resource Group Module Testing Examples

This file contains test scenarios to validate the resource group naming convention.

## Test Scenarios

### Test 1: Security Subscription
```hcl
module "test_security" {
  source = "./modules/resource-group"
  
  subscription_name = "sub_auk_platform_security"
  app_shortcode    = "evh"
  environment      = "prd"
  instance         = "01"
  location         = "UK South"
}

# Expected output: rg-security-evh-prd-01
```

### Test 2: EventHub Subscription
```hcl
module "test_eventhub" {
  source = "./modules/resource-group"
  
  subscription_name = "sub_auk_platform_eventhub"
  app_shortcode    = "msg"
  environment      = "dev"
  instance         = "02"
  location         = "UK West"
}

# Expected output: rg-eventhub-msg-dev-02
```

### Test 3: Sandbox Subscription
```hcl
module "test_sandbox" {
  source = "./modules/resource-group"
  
  subscription_name = "sub_auk_platform_sandbox"
  app_shortcode    = "sbx"
  environment      = "dev"
  instance         = "01"
  location         = "UK South"
}

# Expected output: rg-sandbox-sbx-dev-01
```

### Test 4: Analytics Subscription
```hcl
module "test_analytics" {
  source = "./modules/resource-group"
  
  subscription_name = "sub_auk_platform_analytics"
  app_shortcode    = "dwh"
  environment      = "prd"
  instance         = "03"
  location         = "UK South"
}

# Expected output: rg-analytics-dwh-prd-03
```

### Test 5: Monitoring Subscription
```hcl
module "test_monitoring" {
  source = "./modules/resource-group"
  
  subscription_name = "sub_auk_platform_monitoring"
  app_shortcode    = "mon"
  environment      = "prd"
  instance         = "01"
  location         = "UK South"
}

# Expected output: rg-monitoring-mon-prd-01
```

## Edge Case Testing

### Test 6: Fallback to Legacy Pattern
```hcl
module "test_legacy_fallback" {
  source = "./modules/resource-group"
  
  # No subscription_name provided - should use legacy pattern
  region         = "uks"
  environment    = "prd"
  platform_name  = "platform"
  purpose        = "web"
  app_shortcode  = "web"
  instance       = "01"
  location       = "UK South"
}

# Expected output: uks-prd-platform-web-web-rg-01
```

### Test 7: Invalid Subscription Format
```hcl
module "test_invalid_subscription" {
  source = "./modules/resource-group"
  
  subscription_name = "invalid_format"  # Not enough components
  app_shortcode    = "tst"
  environment      = "dev"
  instance         = "01"
  location         = "UK South"
  purpose          = "fallback"  # Should use this as fallback
}

# Expected output: rg-fallback-tst-dev-01
```

## Validation Tests

### Valid App Short Codes
- ✅ `evh` (2 chars)
- ✅ `sbx` (3 chars) 
- ✅ `dwh` (3 chars)
- ✅ `test` (4 chars)

### Invalid App Short Codes (should fail validation)
- ❌ `e` (1 char - too short)
- ❌ `toolong` (7 chars - too long)

### Valid Environments
- ✅ `prd`
- ✅ `dev`
- ✅ `tst`
- ✅ `stg`
- ✅ `uat`

### Invalid Environments (should fail validation)
- ❌ `prod` (not in allowed list)
- ❌ `test` (not in allowed list)

### Valid Instances
- ✅ `01`
- ✅ `02`
- ✅ `99`

### Invalid Instances (should fail validation)
- ❌ `1` (not 2 digits)
- ❌ `001` (more than 2 digits)
- ❌ `aa` (not numeric)

## Expected Naming Results Summary

| Subscription Name | App Code | Env | Instance | Expected RG Name |
|-------------------|----------|-----|----------|------------------|
| `sub_auk_platform_security` | `evh` | `prd` | `01` | `rg-security-evh-prd-01` |
| `sub_auk_platform_eventhub` | `msg` | `dev` | `02` | `rg-eventhub-msg-dev-02` |
| `sub_auk_platform_sandbox` | `sbx` | `dev` | `01` | `rg-sandbox-sbx-dev-01` |
| `sub_auk_platform_analytics` | `dwh` | `prd` | `03` | `rg-analytics-dwh-prd-03` |
| `sub_auk_platform_monitoring` | `mon` | `prd` | `01` | `rg-monitoring-mon-prd-01` |

## Testing with Terraform

To test these scenarios:

```bash
# Navigate to test directory
cd tests/

# Initialize Terraform
terraform init

# Plan to see the resource names that would be created
terraform plan

# Verify the resource group names match expectations
terraform plan | grep "rg-"
```

## Tag Validation

Each resource group should have these standard tags:
- `Environment`: Matches the environment variable
- `Department`: "TechOps"
- `Source`: "terraform"
- `AppShortCode`: Matches the app_shortcode variable
- `Purpose`: Extracted purpose from subscription name
- `NamingPattern`: "standard" or "legacy"
- `CreatedDate`: Current date in DD-MM-YYYY format
- `ExpiryDate`: 3 years from creation
- `Project`: "CoreServices"
- `CostCenter`: "TBC"
- `RFC`: "TBC"
