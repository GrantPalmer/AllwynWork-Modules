# Quick Start Guide

This guide will help you get started with the Windows VM Domain Join module.

## Prerequisites

1. **Azure CLI installed**: [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **Terraform installed**: [Install Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
3. **Azure subscription**: Access to an Azure subscription

## Step 1: Azure Authentication

Choose one of the following authentication methods:

### Option A: Azure CLI (Recommended)
```bash
# Login to Azure
az login

# List available subscriptions
az account list --output table

# Set your default subscription
az account set --subscription "your-subscription-id-or-name"

# Verify current subscription
az account show
```

### Option B: Environment Variables
```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_TENANT_ID="your-tenant-id"
```

## Step 2: Create Terraform Configuration

Create a `main.tf` file:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

module "windows_vm" {
  source = "path/to/this/module"

  # Required variables
  rgname       = "rg-uks-myapp-prd-01"
  location     = "UK South"
  subnetid     = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.Network/virtualNetworks/YOUR_VNET/subnets/YOUR_SUBNET"
  server_count = 1

  # Naming variables
  purpose       = "web"
  app_shortcode = "myapp"

  # Domain join credentials
  active_directory_username = var.domain_admin_username
  active_directory_password = var.domain_admin_password

  # Optional: Custom tags
  tags = {
    Owner = "your-team@company.com"
  }
}

# Variables for sensitive data
variable "domain_admin_username" {
  description = "Domain administrator username"
  type        = string
  sensitive   = true
}

variable "domain_admin_password" {
  description = "Domain administrator password"
  type        = string
  sensitive   = true
}

# Outputs
output "vm_names" {
  value = module.windows_vm.vm_names
}

output "admin_password" {
  value     = module.windows_vm.admin_password
  sensitive = true
}
```

## Step 3: Create Variables File

Create a `terraform.tfvars` file:

```hcl
# Domain credentials
domain_admin_username = "your-domain-admin@ad.allwyn.co.uk"
domain_admin_password = "your-secure-password"
```

**Important**: Add `terraform.tfvars` to your `.gitignore` file to avoid committing sensitive data.

## Step 4: Deploy

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# When prompted, type 'yes' to confirm
```

## Step 5: Verify Deployment

```bash
# Check the outputs
terraform output

# View sensitive outputs
terraform output -raw admin_password
```

## Common Issues

### Authentication Error
```
Error: building account: unable to configure ResourceManagerAccount: subscription ID could not be determined
```

**Solution**: Ensure you're authenticated with Azure CLI:
```bash
az login
az account set --subscription "your-subscription-id"
```

### Network Issues
Ensure your subnet ID is correct and the subnet has connectivity to your domain controllers.

### Domain Join Issues
- Verify domain admin credentials
- Ensure VMs can reach domain controllers
- Check OU path if specified

## Cleanup

To remove all resources:

```bash
terraform destroy
```

## Next Steps

- Customize VM sizes and configurations
- Add custom tags for your organization
- Set up multiple VMs with different purposes
- Configure custom OU paths for domain join
