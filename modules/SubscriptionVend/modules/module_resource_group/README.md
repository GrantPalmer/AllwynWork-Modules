# Resource Group Naming Convention

This module implements a standardized resource group naming convention that follows the pattern:

```
rg-{subscription_last_component}-{app_short_code}-{environment}-{increment}
```

## Naming Components

| Component | Description | Example Values |
|-----------|-------------|----------------|
| `rg` | Resource type prefix | Always "rg" |
| `subscription_last_component` | Last part of subscription name | "001", "002", "dev" |
| `app_short_code` | Application short code | "sbx", "evh", "sec" |
| `environment` | Environment code | "dev", "prd" |
| `increment` | Resource increment | "01", "02" |

## Examples

### Example 1: Standard Sandbox
**Input:**
- Subscription Name: `AUK-Sandbox-Development-001`
- App Short Code: `sbx`
- Workload: `DevTest`
- Increment: `01`

**Output:** `rg-001-sbx-dev-01`

### Example 2: Event Hub Production
**Input:**
- Subscription Name: `AUK-Production-EventHub-002`
- App Short Code: `evh`
- Workload: `Production`
- Increment: `01`

**Output:** `rg-002-evh-prd-01`

### Example 3: Security Development
**Input:**
- Subscription Name: `AUK-Security-Development`
- App Short Code: `sec`
- Workload: `DevTest`
- Increment: `02`

**Output:** `rg-development-sec-dev-02`

## Configuration

### Variables

```hcl
# In your module call
module "subscription_vend" {
  source = "./modules/SubscriptionVend"
  
  # Subscription configuration
  subscription_name = "AUK-Production-Security-001"
  subscription_workload = "Production"
  
  # Resource naming
  app_short_code = "sec"      # Security application
  resource_increment = "01"   # First resource group
}
```

### Default Values

- **app_short_code**: `"sbx"` (sandbox)
- **resource_increment**: `"01"`
- **environment**: Derived from `subscription_workload`
  - `DevTest` → `dev`
  - `Production` → `prd`

## Environment Mapping

The environment code is automatically derived from the subscription workload:

| Subscription Workload | Environment Code |
|----------------------|------------------|
| `DevTest` | `dev` |
| `Production` | `prd` |

## Validation Rules

### App Short Code
- Must be 2-4 characters
- Lowercase alphanumeric
- Examples: `sbx`, `evh`, `sec`, `web`

### Resource Increment
- Must be exactly 2 digits
- Examples: `01`, `02`, `99`

## Usage in Terraform

```hcl
# The resource group name is automatically generated
output "resource_group_name" {
  value = module.sandbox_rg_01.resource_group_name
  # Example output: "rg-001-sbx-dev-01"
}

# Use in other resources
resource "azurerm_virtual_network" "example" {
  name                = "vnet-example"
  resource_group_name = module.sandbox_rg_01.resource_group_name
  # ...
}
```

## Benefits

1. **Consistency**: All resource groups follow the same naming pattern
2. **Traceability**: Easy to identify subscription and application from name
3. **Environment Clarity**: Clear environment identification
4. **Scalability**: Support for multiple resource groups per application
5. **Automation**: Fully automated name generation

## Migration from Old Naming

If you're migrating from the old `sandbox_rg_01` naming:

### Before:
```
sandbox_rg_01
```

### After:
```
rg-001-sbx-dev-01
```

The new naming provides much more information:
- `001`: From subscription name component
- `sbx`: Sandbox application
- `dev`: Development/DevTest environment
- `01`: First resource group instance
