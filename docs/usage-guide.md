# Usage Guide

This guide explains how to use the Terraform Azure modules in your projects.

## Getting Started

### Prerequisites
- Terraform >= 1.0
- Azure CLI configured
- Azure subscription access
- Appropriate Azure permissions

### Basic Usage

1. **Reference the Module**
```hcl
module "resource_group" {
  source = "git::https://github.com/Allwyn-UK/plat-tf-az-modules//terraform-azurerm-resource-group?ref=v1.0.0"
  
  location      = "UK South"
  region        = "uks"
  env           = "dev"
  platform_name = "myapp"
  purpose       = "web"
  resource_type = "rg"
  resource_suffix = "01"
  
  tags = {
    Project = "MyProject"
    Owner   = "TeamName"
  }
}
```

2. **Use Module Outputs**
```hcl
module "storage_account" {
  source = "git::https://github.com/Allwyn-UK/plat-tf-az-modules//terraform-azurerm-storage-account?ref=v1.0.0"
  
  resource_group_name = module.resource_group.resource_group_name
  location           = module.resource_group.resource_group_location
  # ... other variables
}
```

## Common Patterns

### Standard Resource Naming
All modules follow the naming convention:
```
<region>-<environment>-<platform>-<purpose>-<resource_type>-<instance>
```

Example: `uks-dev-myapp-web-rg-01`

### Environment Configuration
```hcl
# Development Environment
env = "dev"
region = "uks"

# Production Environment  
env = "prd"
region = "uks"
```

### Tagging Strategy
```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.team_name
    CostCenter  = var.cost_center
    Source      = "terraform"
  }
}

# Use in module calls
tags = merge(local.common_tags, var.additional_tags)
```

## Module Categories

### Core Infrastructure
- `terraform-azurerm-resource-group` - Resource groups
- `terraform-azurerm-virtual-network` - Virtual networks and subnets
- `terraform-azurerm-network-security-group` - Network security groups

### Compute
- `terraform-azurerm-windows-virtual-machine` - Windows VMs
- `terraform-azurerm-linux-virtual-machine` - Linux VMs
- `terraform-azurerm-azure-kubernetes-service` - AKS clusters

### Storage
- `terraform-azurerm-storage-account` - Storage accounts
- `terraform-azurerm-storage-container` - Blob containers

### Security
- `terraform-azurerm-key-vault` - Key Vault
- `terraform-azurerm-user-assigned-identity` - Managed identities

## Best Practices

### Version Pinning
Always pin module versions:
```hcl
source = "git::https://github.com/Allwyn-UK/plat-tf-az-modules//terraform-azurerm-resource-group?ref=v1.2.0"
```

### Variable Validation
Leverage built-in variable validation:
```hcl
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "tst", "stg", "prd"], var.environment)
    error_message = "Environment must be one of: dev, tst, stg, prd."
  }
}
```

### Resource Dependencies
Use module outputs to create dependencies:
```hcl
# Correct - explicit dependency
subnet_id = module.virtual_network.subnet_ids["web"]

# Avoid - implicit dependencies may cause issues
subnet_id = data.azurerm_subnet.web.id
```

## Example Configurations

### Simple Web Application
```hcl
# Resource Group
module "rg" {
  source = "git::https://github.com/Allwyn-UK/plat-tf-az-modules//terraform-azurerm-resource-group?ref=v1.0.0"
  
  location        = "UK South"
  region          = "uks"
  env             = "dev"
  platform_name   = "webapp"
  purpose         = "main"
  resource_type   = "rg"
  resource_suffix = "01"
  
  tags = local.common_tags
}

# Virtual Network
module "vnet" {
  source = "git::https://github.com/Allwyn-UK/plat-tf-az-modules//terraform-azurerm-virtual-network?ref=v1.0.0"
  
  resource_group_name = module.rg.resource_group_name
  location           = module.rg.resource_group_location
  
  # ... other configuration
}
```

## Troubleshooting

### Common Issues
1. **Provider version conflicts** - Ensure all modules use compatible provider versions
2. **Naming conflicts** - Verify resource names are unique within scope
3. **Permission issues** - Check Azure RBAC permissions

### Debug Commands
```bash
# Validate configuration
terraform validate

# Check formatting
terraform fmt -check

# Plan with detailed logs
TF_LOG=DEBUG terraform plan
```
