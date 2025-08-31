# User Access Management Examples

This document provides examples of how to assign users to resource groups with different roles.

## Basic User Assignment

### Example 1: Security Team Resource Group
```hcl
module "security_team_rg" {
  source = "./modules/resource-group"
  
  # Resource configuration
  subscription_name = "sub_auk_platform_security"
  app_shortcode    = "sec"
  environment      = "prd"
  instance         = "01"
  location         = "UK South"
  
  # Security team as contributors
  contributor_users = [
    "security.admin@allwyn.co.uk",
    "security.analyst@allwyn.co.uk",
    "incident.responder@allwyn.co.uk"
  ]
  
  # Security director as owner
  owner_users = [
    "security.director@allwyn.co.uk"
  ]
  
  # Auditors as readers
  reader_users = [
    "audit.team@allwyn.co.uk",
    "compliance.officer@allwyn.co.uk"
  ]
}
# Result: rg-security-sec-prd-01
```

### Example 2: Development Team Resource Group
```hcl
module "dev_team_rg" {
  source = "./modules/resource-group"
  
  subscription_name = "sub_auk_platform_sandbox"
  app_shortcode    = "dev"
  environment      = "dev"
  instance         = "01"
  location         = "UK South"
  
  # Developers as contributors
  contributor_users = [
    "john.developer@allwyn.co.uk",
    "jane.developer@allwyn.co.uk",
    "mike.devops@allwyn.co.uk"
  ]
  
  # Team lead as owner
  owner_users = [
    "team.lead@allwyn.co.uk"
  ]
  
  # QA team as readers
  reader_users = [
    "qa.tester@allwyn.co.uk"
  ]
}
# Result: rg-sandbox-dev-dev-01
```

### Example 3: Production EventHub Resource Group
```hcl
module "eventhub_prod_rg" {
  source = "./modules/resource-group"
  
  subscription_name = "sub_auk_platform_eventhub"
  app_shortcode    = "evh"
  environment      = "prd"
  instance         = "01"
  location         = "UK South"
  
  # Platform team as contributors
  contributor_users = [
    "platform.engineer@allwyn.co.uk",
    "data.engineer@allwyn.co.uk"
  ]
  
  # Platform manager as owner
  owner_users = [
    "platform.manager@allwyn.co.uk"
  ]
  
  # Multiple teams as readers
  reader_users = [
    "app.team1@allwyn.co.uk",
    "app.team2@allwyn.co.uk",
    "monitoring.team@allwyn.co.uk",
    "business.analyst@allwyn.co.uk"
  ]
}
# Result: rg-eventhub-evh-prd-01
```

## Advanced Scenarios

### Example 4: Mixed Environment Access
```hcl
module "analytics_rg" {
  source = "./modules/resource-group"
  
  subscription_name = "sub_auk_platform_analytics"
  app_shortcode    = "dwh"
  environment      = "prd"
  instance         = "01"
  location         = "UK South"
  
  # Data engineers as contributors
  contributor_users = [
    "data.engineer1@allwyn.co.uk",
    "data.engineer2@allwyn.co.uk",
    "etl.developer@allwyn.co.uk"
  ]
  
  # Data architect as owner
  owner_users = [
    "data.architect@allwyn.co.uk"
  ]
  
  # Business users as readers
  reader_users = [
    "business.intelligence@allwyn.co.uk",
    "data.analyst@allwyn.co.uk",
    "reporting.team@allwyn.co.uk"
  ]
  
  # Custom tags
  tags = {
    CostCenter = "DATA-001"
    Project    = "Enterprise Data Warehouse"
    Owner      = "Data Team"
  }
}
# Result: rg-analytics-dwh-prd-01
```

### Example 5: Service Principal Access
```hcl
module "automation_rg" {
  source = "./modules/resource-group"
  
  subscription_name = "sub_auk_platform_automation"
  app_shortcode    = "auto"
  environment      = "prd"
  instance         = "01"
  location         = "UK South"
  
  # Automation team as contributors
  contributor_users = [
    "automation.engineer@allwyn.co.uk",
    "devops.engineer@allwyn.co.uk"
  ]
  
  # Platform owner
  owner_users = [
    "platform.owner@allwyn.co.uk"
  ]
  
  # Monitoring and support as readers
  reader_users = [
    "monitoring.team@allwyn.co.uk",
    "support.team@allwyn.co.uk"
  ]
}
# Result: rg-automation-auto-prd-01
```

## Role Permissions Summary

| Role | Permissions | Use Cases |
|------|-------------|-----------|
| **Owner** | Full access + manage access | Team leads, managers, architects |
| **Contributor** | Create/modify/delete resources | Engineers, developers, operators |
| **Reader** | View resources and configurations | Auditors, business users, monitoring |

## Best Practices

### **1. Principle of Least Privilege**
```hcl
# ✅ Good: Specific roles for specific needs
contributor_users = ["developer@allwyn.co.uk"]  # Needs to deploy
reader_users = ["auditor@allwyn.co.uk"]        # Only needs to view

# ❌ Avoid: Everyone as owner
owner_users = ["everyone@allwyn.co.uk"]        # Too broad access
```

### **2. Team-Based Access**
```hcl
# ✅ Good: Role-based assignments
contributor_users = [
  "dev.team.lead@allwyn.co.uk",
  "senior.developer@allwyn.co.uk"
]
reader_users = [
  "qa.team@allwyn.co.uk",
  "support.team@allwyn.co.uk"
]
```

### **3. Environment-Specific Access**
```hcl
# Production - Limited contributors
module "prod_rg" {
  contributor_users = ["senior.engineer@allwyn.co.uk"]
  owner_users      = ["platform.manager@allwyn.co.uk"]
}

# Development - More open access
module "dev_rg" {
  contributor_users = [
    "junior.dev@allwyn.co.uk",
    "senior.dev@allwyn.co.uk",
    "intern@allwyn.co.uk"
  ]
}
```

## Troubleshooting

### **Common Issues:**

#### **User Not Found Error**
```
Error: User 'user@allwyn.co.uk' not found
```
**Solution:** Verify the user exists in Azure AD and UPN is correct

#### **Insufficient Permissions**
```
Error: Principal does not have sufficient permissions
```
**Solution:** Ensure service principal has User.Read.All API permission

#### **Role Assignment Failed**
```
Error: Cannot assign role to user
```
**Solution:** Check if service principal has sufficient RBAC permissions

## Validation Commands

```bash
# List role assignments for a resource group
az role assignment list --resource-group "rg-security-evh-prd-01" --output table

# Check user exists in Azure AD
az ad user show --id "user@allwyn.co.uk"

# Verify service principal permissions
az ad sp show --id <service-principal-id> --query "appRoles"
```

## Outputs Available

After deployment, you can access:

```hcl
# List of assigned users by role
output "contributors" {
  value = module.security_rg.contributor_users_assigned
}

# Detailed role assignment information
output "all_assignments" {
  value = module.security_rg.role_assignments
}
```
