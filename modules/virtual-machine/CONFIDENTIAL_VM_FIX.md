# Confidential VM Error Fix Guide

## Your Current Error
```
The VM size 'Standard_DC4s_v3' is not supported for creation of VMs with 'ConfidentialVM' security type and managedDisk.securityProfile.securityEncryptionType set as 'VMGuestStateOnly'
```

## The Problem
`Standard_DC4s_v3` is an **older generation DC-series VM** that doesn't support the newer Confidential VM features with security encryption.

## Quick Fix Options

### Option 1: Use Compatible Confidential VM Size (Recommended)
Update your module call to use a DCasv5-series VM:

```hcl
module "windows_vm" {
  source = "../../modules/virtual-machine"
  
  # Use Confidential VM compatible size
  size = "Standard_DC4as_v5"  # or Standard_DC2as_v5, Standard_DC8as_v5
  
  # Enable Confidential VM features
  enable_confidential_vm = true
  enable_generation_2    = true
  security_encryption_type = "VMGuestStateOnly"
  
  # Rest of your configuration...
}
```

### Option 2: Disable Confidential VM Features
If you don't need Confidential Computing, disable the security encryption:

```hcl
module "windows_vm" {
  source = "../../modules/virtual-machine"
  
  # Keep your current size
  size = "Standard_DC4s_v3"
  
  # Disable Confidential VM features
  enable_confidential_vm = false
  enable_generation_2    = true  # Can still use Gen 2 without CVM
  
  # Rest of your configuration...
}
```

### Option 3: Use Standard VM Size
Use a regular VM size without Confidential features:

```hcl
module "windows_vm" {
  source = "../../modules/virtual-machine"
  
  # Use standard VM size
  size = "Standard_D4s_v5"  # Similar performance to DC4s_v3
  
  # Standard configuration
  enable_confidential_vm = false
  enable_generation_2    = true
  
  # Rest of your configuration...
}
```

## Confidential VM Compatible Sizes

### DCasv5-series (AMD-based Confidential VMs)
- `Standard_DC2as_v5` - 2 vCPUs, 8 GB RAM
- `Standard_DC4as_v5` - 4 vCPUs, 16 GB RAM  
- `Standard_DC8as_v5` - 8 vCPUs, 32 GB RAM
- `Standard_DC16as_v5` - 16 vCPUs, 64 GB RAM
- `Standard_DC32as_v5` - 32 vCPUs, 128 GB RAM
- `Standard_DC48as_v5` - 48 vCPUs, 192 GB RAM
- `Standard_DC64as_v5` - 64 vCPUs, 256 GB RAM
- `Standard_DC96as_v5` - 96 vCPUs, 384 GB RAM

### ECasv5-series (AMD-based Memory Optimized Confidential VMs)
- `Standard_EC2as_v5` - 2 vCPUs, 16 GB RAM
- `Standard_EC4as_v5` - 4 vCPUs, 32 GB RAM
- `Standard_EC8as_v5` - 8 vCPUs, 64 GB RAM
- `Standard_EC16as_v5` - 16 vCPUs, 128 GB RAM

## Size Comparison
Your current `Standard_DC4s_v3` specifications:
- 4 vCPUs, 16 GB RAM

Equivalent Confidential VM options:
- `Standard_DC4as_v5` - 4 vCPUs, 16 GB RAM (exact match)
- `Standard_EC4as_v5` - 4 vCPUs, 32 GB RAM (more memory)

## Example Module Configuration (Your Fix)

```hcl
module "windows_vm" {
  source = "../../modules/virtual-machine"

  # Your existing configuration
  region          = "uks"
  environment     = "prd"  
  purpose         = "pwsh"
  app_shortcode   = "AUK"
  instance        = "01"
  rgname          = "rg-authentication-pwsh-prd-01"
  location        = "UK South"
  subnetid        = var.subnet_id
  server_count    = 1

  # FIXED: Use Confidential VM compatible size
  size = "Standard_DC4as_v5"

  # Confidential VM configuration
  enable_confidential_vm   = true
  enable_generation_2      = true
  security_encryption_type = "VMGuestStateOnly"

  # Domain configuration
  active_directory_domain    = "ad.allwyn.co.uk"
  active_directory_username  = var.ad_username
  active_directory_password  = var.ad_password
  
  # Rest of your configuration...
}
```

## Verification
After applying the fix, check the output:

```bash
terraform output generation_2_features
```

Should show:
```
{
  confidential_vm_enabled = true
  is_confidential_size   = true
  security_encryption    = "VMGuestStateOnly"
  vm_size               = "Standard_DC4as_v5"
}
```
