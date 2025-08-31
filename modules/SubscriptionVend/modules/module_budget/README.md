# Budget Module Naming Convention

This module implements a standardized budget naming convention that follows the pattern:

```
bg-{subscription_last_component}-{app_short_code}-{environment}-{increment}
```

## Naming Components

| Component | Description | Example Values |
|-----------|-------------|----------------|
| `bg` | Resource type prefix | Always "bg" (budget) |
| `subscription_last_component` | Last part of subscription name | "001", "002", "dev" |
| `app_short_code` | Application short code | "sbx", "evh", "sec" |
| `environment` | Environment code | "dev", "prd" |
| `increment` | Budget increment | "01", "02" |

## Examples

### Example 1: Standard Sandbox Budget
**Input:**
- Subscription Name: `AUK-Sandbox-Development-001`
- App Short Code: `sbx`
- Workload: `DevTest`
- Increment: `01`

**Output:** `bg-001-sbx-dev-01`

### Example 2: Event Hub Production Budget
**Input:**
- Subscription Name: `AUK-Production-EventHub-002`
- App Short Code: `evh`
- Workload: `Production`
- Increment: `01`

**Output:** `bg-002-evh-prd-01`

### Example 3: Security Development Budget
**Input:**
- Subscription Name: `AUK-Security-Development`
- App Short Code: `sec`
- Workload: `DevTest`
- Increment: `02`

**Output:** `bg-development-sec-dev-02`

## Budget Features

### Notification Thresholds
The module automatically creates three notification levels:

| Threshold | Type | Description |
|-----------|------|-------------|
| 80% | Actual | Warning when 80% of budget is consumed |
| 90% | Actual | Alert when 90% of budget is consumed |
| 100% | Forecasted | Alert when budget is forecasted to be exceeded |

### Default Configuration
- **Budget Amount**: £100 annually (configurable)
- **Time Grain**: Annual
- **Contact Roles**: Owner, Reader
- **Start Date**: Current month
- **End Date**: 2050-01-01 (effectively no end)

## Configuration

### Variables

```hcl
# In your module call
module "subscription_budget" {
  source = "./modules/module_budget"
  
  # Subscription configuration
  subscription_name = "AUK-Production-Security-001"
  app_short_code = "sec"
  environment = "prd"
  
  # Budget configuration
  budget_amount = 500         # £500 annually
  increment = "01"            # First budget
  budget_contacts = [
    "finance@allwyn.co.uk",
    "grant.palmer@allwyn.co.uk"
  ]
}
```

### Default Values

- **budget_amount**: `100` (£100)
- **increment**: `"01"`
- **budget_contacts**: `["grant.palmer@allwyn.co.uk"]`

## Usage in Main Module

```hcl
module "sub_budget_01" {
  source = "./modules/module_budget"
  subscription_name = var.subscription_name
  app_short_code = var.app_short_code
  environment = local.environment_code
  budget_amount = var.budget_amount
  increment = var.resource_increment
  budget_contacts = var.budget_contacts
}
```

## Outputs

| Name | Description | Example |
|------|-------------|---------|
| `budget_id` | Azure resource ID of the budget | `/subscriptions/.../budgets/bg-001-sbx-dev-01` |
| `budget_name` | Generated budget name | `bg-001-sbx-dev-01` |
| `budget_amount` | Budget amount configured | `100` |

## Notification Details

### Email Notifications
- **Recipients**: Configured contact emails + Azure role holders
- **Roles Notified**: Owner, Reader
- **Frequency**: When thresholds are crossed

### Notification Content
- **80% Threshold**: "Budget Warning - 80% consumed"
- **90% Threshold**: "Budget Alert - 90% consumed"  
- **100% Forecasted**: "Budget Forecast Alert - Overage predicted"

## Benefits

1. **Cost Control**: Automatic alerts prevent budget overruns
2. **Consistency**: All budgets follow the same naming pattern
3. **Traceability**: Easy to identify subscription and application from name
4. **Environment Clarity**: Clear environment identification
5. **Scalability**: Support for multiple budgets per application
6. **Governance**: Built-in approval and monitoring workflow

## Integration with Azure Cost Management

The budgets created by this module integrate with:
- **Azure Cost Management**: View in Azure portal
- **Power BI**: Export cost data and alerts
- **Logic Apps**: Trigger automated actions on budget alerts
- **Azure Monitor**: Integrate with alerting infrastructure

## Migration from Old Naming

If you're migrating from the old budget naming:

### Before:
```
AUK-SBX-Sandbox-001_Budget_01
```

### After:
```
bg-001-sbx-dev-01
```

The new naming provides:
- **Shorter names**: More Azure-friendly format
- **Consistent pattern**: Matches other resources
- **Better parsing**: Easier for automation scripts
- **Clear hierarchy**: Obvious relationship to subscription and app

## Monitoring and Alerts

### Email Alerts
All configured contacts receive email notifications when:
- Budget reaches 80% consumption
- Budget reaches 90% consumption
- Budget is forecasted to exceed 100%

### Azure Portal Integration
- View budget status in Cost Management
- See spending trends and forecasts
- Configure additional alerts if needed

### Automation Opportunities
- **Logic Apps**: Trigger automated responses to budget alerts
- **Azure Functions**: Custom actions when thresholds are reached
- **Service Now**: Create tickets for budget overruns
- **Slack/Teams**: Send notifications to chat channels
