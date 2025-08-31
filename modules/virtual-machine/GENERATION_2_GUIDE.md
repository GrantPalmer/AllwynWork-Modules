# Generation 2 Virtual Machine Configuration Guide

This document provides comprehensive guidance on deploying Generation 2 Azure Virtual Machines using the enhanced virtual machine module.

## What are Generation 2 VMs?

Generation 2 VMs in Azure provide enhanced security features and improved performance compared to Generation 1 VMs. They include:

- **Secure Boot**: Protects against rootkits and boot kits
- **Virtual TPM (vTPM)**: Hardware-based security for encryption keys and attestation
- **Enhanced Security**: Support for confidential computing and advanced encryption
- **UEFI Firmware**: Faster boot times and improved hardware support
- **Larger Boot Volume**: Support for larger OS disks (up to 4TB)

## Module Configuration for Generation 2

### Default Configuration
By default, the module is now configured to deploy Generation 2 VMs:

```hcl
# Default vm_image now uses Generation 2
vm_image = {
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2022-datacenter-g2"  # Generation 2 SKU
  version   = "latest"
}

# Generation 2 features enabled by default
enable_generation_2     = true
enable_secure_boot     = true
enable_vtpm           = true
security_encryption_type = "VMGuestStateOnly"
```

### Generation 2 Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_generation_2` | bool | `true` | Enable Generation 2 VM deployment |
| `enable_secure_boot` | bool | `true` | Enable Secure Boot (requires Gen 2) |
| `enable_vtpm` | bool | `true` | Enable Virtual TPM (requires Gen 2) |
| `security_encryption_type` | string | `"VMGuestStateOnly"` | Security encryption type |

### Security Encryption Types

1. **VMGuestStateOnly**: Encrypts VM guest state and temporary disks
2. **DiskWithVMGuestState**: Encrypts both VM guest state and OS/data disks

## Compatible VM Images

### Windows Server 2022 Generation 2 SKUs

| SKU | Description | Best For |
|-----|-------------|----------|
| `2022-datacenter-g2` | Standard Generation 2 | General workloads |
| `2022-datacenter-azure-edition-g2` | Azure Edition with enhanced features | Cloud-optimized workloads |
| `2022-datacenter-core-g2` | Server Core Generation 2 | Minimal footprint deployments |

### Windows Server 2019 Generation 2 SKUs

| SKU | Description |
|-----|-------------|
| `2019-datacenter-gensecond` | Windows Server 2019 Generation 2 |
| `2019-datacenter-core-gensecond` | Server Core 2019 Generation 2 |

### Windows 11 Enterprise SKUs

| SKU | Description |
|-----|-------------|
| `win11-22h2-ent-g2` | Windows 11 Enterprise Generation 2 |
| `win11-21h2-ent-g2` | Windows 11 Enterprise 21H2 Generation 2 |

## Configuration Examples

### 1. Standard Generation 2 Configuration
```hcl
module "standard_gen2_vm" {
  source = "../../modules/virtual-machine"
  
  # Basic configuration
  region       = "uks"
  environment  = "dev"
  purpose      = "web"
  # ... other required variables ...
  
  # Generation 2 (uses defaults)
  enable_generation_2 = true
  
  # Standard image
  vm_image = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
}
```

### 2. Maximum Security Configuration
```hcl
module "secure_gen2_vm" {
  source = "../../modules/virtual-machine"
  
  # ... basic configuration ...
  
  # Maximum Generation 2 security
  enable_generation_2           = true
  enable_secure_boot           = true
  enable_vtpm                  = true
  security_encryption_type     = "DiskWithVMGuestState"
  enable_encryption_at_host     = true
  
  # Azure Edition image with enhanced features
  vm_image = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-g2"
    version   = "latest"
  }
  
  # Premium storage for better performance
  os_disk_storage_account_type = "Premium_LRS"
}
```

### 3. Disable Generation 2 (Legacy Support)
```hcl
module "legacy_vm" {
  source = "../../modules/virtual-machine"
  
  # ... basic configuration ...
  
  # Disable Generation 2 features
  enable_generation_2 = false
  
  # Use Generation 1 image
  vm_image = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"  # No -g2 suffix
    version   = "latest"
  }
}
```

## VM Size Compatibility

Most modern Azure VM sizes support Generation 2 VMs. Recommended sizes include:

### General Purpose
- Standard_D2s_v5, Standard_D4s_v5, Standard_D8s_v5
- Standard_B2ms, Standard_B4ms (Burstable)

### Memory Optimized
- Standard_E2s_v5, Standard_E4s_v5, Standard_E8s_v5

### Compute Optimized
- Standard_F2s_v2, Standard_F4s_v2, Standard_F8s_v2

## Security Benefits

### With Generation 2 Enabled:
✅ **Secure Boot**: Protects against malicious boot code  
✅ **vTPM**: Hardware-based security for BitLocker and Attestation  
✅ **UEFI**: Modern firmware with enhanced security  
✅ **Enhanced Encryption**: VM guest state protection  
✅ **Trusted Launch**: Platform integrity verification  

### Additional Security (when using DiskWithVMGuestState):
✅ **OS Disk Encryption**: Enhanced disk-level protection  
✅ **Confidential Computing Ready**: Prepared for confidential VM features  

## Troubleshooting

### Common Issues

1. **VM Size Not Compatible**
   - Error: "The VM size does not support Generation 2"
   - Solution: Use a compatible VM size (most v5 series support Gen 2)

2. **Image SKU Not Generation 2**
   - Error: "The selected image is not Generation 2 compatible"
   - Solution: Ensure the SKU ends with `-g2` or use Azure Edition images

3. **Feature Dependencies**
   - Secure Boot and vTPM require `enable_generation_2 = true`
   - Security encryption requires Generation 2 VM

### Validation Checklist

Before deployment, verify:
- [ ] VM size supports Generation 2
- [ ] Image SKU is Generation 2 compatible (contains `-g2` or similar)
- [ ] `enable_generation_2 = true` is set
- [ ] Required security features are properly configured

## Migration from Generation 1

To migrate existing Generation 1 VMs to Generation 2:

1. **Backup existing VM**
2. **Update module configuration**:
   ```hcl
   enable_generation_2 = true
   vm_image = {
     # ... Generation 2 compatible image
     sku = "2022-datacenter-g2"
   }
   ```
3. **Recreate VM** (no in-place upgrade possible)
4. **Restore data** from backup

## Best Practices

1. **Always use Generation 2** for new deployments
2. **Enable Secure Boot and vTPM** for maximum security
3. **Use Premium storage** for production workloads
4. **Choose appropriate encryption type** based on security requirements
5. **Test configurations** in development environment first
6. **Document security settings** for compliance purposes

## Monitoring Generation 2 Features

The module provides outputs to monitor Generation 2 status:

```hcl
output "generation_2_status" {
  value = module.vm.generation_2_features
}
```

This outputs:
```
{
  generation_2_enabled = true
  secure_boot_enabled  = true
  vtpm_enabled        = true
  security_encryption = "VMGuestStateOnly"
  vm_image_sku       = "2022-datacenter-g2"
}
```
