# plat-tf-az-modules
Shared Terraform Azure Modules

## Overview

This repository contains reusable Terraform modules for Azure infrastructure components. These modules follow standardized patterns and best practices for consistent infrastructure deployment across environments.

## Documentation

📚 **[Full Documentation](./docs/README.md)**

Quick Links:
- [Usage Guide](./docs/usage-guide.md) - How to use the modules
- [Module Standards](./docs/module-standards.md) - Development standards and conventions
- [Contributing](./docs/contributing.md) - Guidelines for contributors
- [Troubleshooting](./docs/troubleshooting.md) - Common issues and solutions
- [Provider Requirements](./docs/provider-requirements.md) - Azure provider version requirements

## Quick Start

```hcl
module "resource_group" {
  source = "git::https://github.com/Allwyn-UK/plat-tf-az-modules//terraform-azurerm-resource-group?ref=v1.0.0"
  
  location        = "UK South"
  region          = "uks"
  env             = "dev"
  platform_name   = "myapp"
  purpose         = "web"
  resource_type   = "rg"
  resource_suffix = "01"
  
  tags = {
    Project = "MyProject"
    Owner   = "TeamName"
  }
}
```

## Available Modules

### Core Infrastructure
- `terraform-azurerm-resource-group` - Resource groups
- `terraform-azurerm-virtual-network` - Virtual networks and subnets
- `terraform-azurerm-network-security-group` - Network security groups

### Compute
- `terraform-azurerm-windows-virtual-machine` - Windows virtual machines
- `terraform-azurerm-linux-virtual-machine` - Linux virtual machines
- `terraform-azurerm-azure-kubernetes-service` - AKS clusters

### Storage
- `terraform-azurerm-storage-account` - Storage accounts
- `terraform-azurerm-storage-container` - Blob containers

### Security
- `terraform-azurerm-key-vault` - Azure Key Vault
- `terraform-azurerm-user-assigned-identity` - Managed identities

## Requirements

- Terraform >= 1.0
- Azure Provider >= 3.116.0
- Azure CLI configured
- Appropriate Azure permissions

## Support

For issues, questions, or contributions:
1. Check the [troubleshooting guide](./docs/troubleshooting.md)
2. Review existing [GitHub issues](../../issues)
3. Create a new issue with detailed information
4. Follow the [contributing guidelines](./docs/contributing.md)
