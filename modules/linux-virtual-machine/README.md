# Linux Virtual Machine Module

This Terraform module creates and configures Linux virtual machines in Azure, specifically optimized for Ubuntu 24.04 LTS with Generation 2 VM support and optional Confidential Computing capabilities.

## Features

### 🚀 **Core VM Capabilities**
- **Ubuntu 24.04 LTS**: Latest long-term support release with Generation 2 compatibility
- **Generation 2 VMs**: Enhanced security with UEFI firmware, Secure Boot, and vTPM
- **Confidential Computing**: Optional support for DCasv5/ECasv5 series with hardware-level encryption
- **SSH Key Authentication**: Secure key-based authentication (password auth disabled by default)
- **Custom Data Scripts**: Automated Ubuntu setup and configuration

### 🔒 **Security Features**
- **Secure Boot**: UEFI Secure Boot for verified boot process
- **vTPM**: Virtual Trusted Platform Module for cryptographic operations
- **Encryption at Host**: Host-level encryption for data at rest
- **UFW Firewall**: Uncomplicated Firewall configured and enabled
- **Fail2ban**: SSH brute-force protection
- **SSH Hardening**: Secure SSH configuration with key-only authentication

### 📊 **Monitoring & Management**
- **Azure Monitor Agent**: Comprehensive monitoring and logging
- **Dependency Agent**: Application dependency mapping
- **Guest Configuration**: Policy compliance and configuration management
- **Boot Diagnostics**: VM startup troubleshooting
- **Automatic Patching**: Managed OS updates

### 🗂️ **Syslog Server Capabilities**
- **Centralized Logging**: Enterprise-grade syslog server with rsyslog
- **Multi-protocol Support**: UDP, TCP, and TLS encryption (ports 514/6514)
- **Network Filtering**: CIDR-based source filtering for security
- **Log Organization**: Automatic separation by hostname and application
- **Custom Rules**: Flexible log filtering and routing
- **Log Rotation**: Configurable retention and automatic cleanup
- **Real-time Monitoring**: Built-in status monitoring and alerting

### 🏷️ **Resource Management**
- **Consistent Naming**: Standardized Azure naming conventions
- **Rich Tagging**: Comprehensive tagging strategy with timestamps
- **Auto-scheduling**: VM start/stop scheduling support
- **Multiple Instances**: Support for creating multiple identical VMs

## Quick Start

### Basic Usage

```hcl
module "linux_vm" {
  source = "../../modules/linux-virtual-machine"

  # Basic Configuration
  region          = "uks"
  environment     = "dev"
  purpose         = "web"
  app_shortcode   = "APP"
  instance        = "01"
  
  # Infrastructure
  rgname          = "rg-app-web-dev-01"
  location        = "UK South"
  subnetid        = var.subnet_id
  server_count    = 1
  size            = "Standard_B2ms"

  # SSH Authentication
  admin_username      = "ubuntu-admin"
  admin_ssh_public_key = file("~/.ssh/id_rsa.pub")
}
```

### Production Example with Monitoring

```hcl
module "production_linux_vm" {
  source = "../../modules/linux-virtual-machine"

  # Production Configuration
  region          = "uks"
  environment     = "prd"
  purpose         = "app"
  app_shortcode   = "CRM"
  instance        = "01"
  
  # Infrastructure
  rgname          = "rg-crm-app-prd-01"
  location        = "UK South"
  subnetid        = var.subnet_id
  server_count    = 2
  size            = "Standard_D4s_v5"

  # Security & Performance
  enable_generation_2      = true
  enable_secure_boot       = true
  enable_vtpm             = true
  enable_encryption_at_host = true
  os_disk_storage_account_type = "Premium_LRS"

  # SSH Configuration
  admin_username              = "app-admin"
  admin_ssh_public_key        = var.ssh_public_key
  disable_password_authentication = true

  # Monitoring
  enable_azure_monitor        = true
  enable_dependency_agent     = true
  enable_guest_configuration  = true
  data_collection_rule_id     = var.dcr_id

  # Management
  enable_patch_management     = true
  enable_boot_diagnostics     = true
  
  # Tagging
  department    = "Engineering"
  project       = "CRM Platform"
  cost_center   = "TECH-001"
  rfc           = "RFC-2024-001"
  
  tags = {
    Application = "CRM"
    Owner       = "platform-team@company.com"
  }
}
```

### Syslog Server Example

```hcl
module "syslog_server" {
  source = "../../modules/linux-virtual-machine"

  # Syslog Server Configuration
  region          = "uks"
  environment     = "prd"
  purpose         = "syslog"
  app_shortcode   = "LOG"
  
  # Infrastructure
  rgname          = "rg-logging-hub-prd-01"
  location        = "UK South"
  subnetid        = var.subnet_id
  server_count    = 1
  size            = "Standard_D4s_v5"  # 4 vCPUs for log processing

  # Syslog Configuration
  enable_syslog_server     = true
  syslog_port             = 514
  syslog_protocol         = "both"    # UDP and TCP
  enable_syslog_tls       = true      # Enable TLS on port 6514
  syslog_allowed_networks = [
    "10.0.0.0/8",
    "172.16.0.0/12", 
    "192.168.0.0/16"
  ]
  syslog_log_retention_days = 90      # 3 months retention
  syslog_max_log_size      = "500M"   # 500MB max file size

  # Custom filtering rules
  syslog_custom_rules = [
    ":syslogtag, contains, \"ERROR\" /var/log/remote/critical/error.log",
    ":programname, contains, \"ssh\" /var/log/remote/security/ssh.log"
  ]

  # SSH Configuration  
  admin_username      = "syslog-admin"
  admin_ssh_public_key = var.ssh_public_key
}
```

## Configuration Reference

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `purpose` | string | The purpose of the VM (e.g., "web", "app", "db") |
| `rgname` | string | Resource group name |
| `location` | string | Azure location |
| `subnetid` | string | Subnet ID for VM network interface |
| `server_count` | number | Number of VMs to create |
| `admin_ssh_public_key` | string | SSH public key for admin authentication |

### Key Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `size` | string | `"Standard_B2ms"` | VM size (use DCasv5/ECasv5 for Confidential VMs) |
| `vm_image` | map | Ubuntu 24.04 LTS Gen2 | VM image configuration |
| `enable_generation_2` | bool | `true` | Enable Generation 2 VM features |
| `enable_confidential_vm` | bool | `false` | Enable Confidential Computing |
| `enable_syslog_server` | bool | `false` | Enable centralized syslog server |
| `syslog_port` | number | `514` | Syslog server listening port |
| `syslog_protocol` | string | `"both"` | Syslog protocol (udp, tcp, both) |
| `enable_syslog_tls` | bool | `true` | Enable TLS encryption for syslog |
| `syslog_allowed_networks` | list(string) | RFC1918 ranges | Networks allowed to send logs |
| `admin_username` | string | `"brc-adminuser"` | Admin username |
| `disable_password_authentication` | bool | `true` | Disable password auth (SSH only) |
| `timezone` | string | `"Europe/London"` | System timezone |

## VM Sizes and Compatibility

### Standard Sizes (Generation 2)
- `Standard_B2ms` - 2 vCPUs, 8 GB RAM (General Purpose)
- `Standard_D4s_v5` - 4 vCPUs, 16 GB RAM (General Purpose)
- `Standard_E4s_v5` - 4 vCPUs, 32 GB RAM (Memory Optimized)

### Confidential Computing Sizes (DCasv5/ECasv5)
- `Standard_DC2as_v5` - 2 vCPUs, 8 GB RAM
- `Standard_DC4as_v5` - 4 vCPUs, 16 GB RAM
- `Standard_DC8as_v5` - 8 vCPUs, 32 GB RAM
- `Standard_EC4as_v5` - 4 vCPUs, 32 GB RAM (Memory Optimized)

## Security Features

### SSH Configuration
- **Key-based authentication** only (passwords disabled by default)
- **SSH hardening** with secure configuration
- **Fail2ban** protection against brute force attacks

### Firewall & Network Security
- **UFW firewall** enabled with default deny policy
- **SSH access** allowed by default
- **Network security groups** should be configured at subnet level

### VM Security
- **Generation 2** VMs with UEFI firmware
- **Secure Boot** enabled by default
- **vTPM** (Virtual Trusted Platform Module) enabled
- **Encryption at host** available
- **Confidential Computing** for sensitive workloads

## Monitoring and Management

### Azure Monitor Integration
```hcl
# Enable full monitoring stack
enable_azure_monitor       = true
enable_dependency_agent    = true
enable_guest_configuration = true
data_collection_rule_id    = azurerm_monitor_data_collection_rule.vm_dcr.id
```

### Patch Management
```hcl
# Enable automatic patching
enable_patch_management = true
patch_mode             = "AutomaticByPlatform"
```

## Custom Data Script

The module includes an Ubuntu 24.04 setup script that:
- Updates system packages
- Configures timezone
- Installs essential tools
- Sets up security (UFW, fail2ban)
- Configures SSH hardening
- Sets up automatic security updates

### Custom Script Override
```hcl
module "linux_vm" {
  source = "../../modules/linux-virtual-machine"
  
  # Use custom setup script
  custom_data = base64encode(file("path/to/your/script.sh"))
  
  # ... other configuration
}
```

## Outputs

The module provides comprehensive outputs including:

- `vm_names` - VM names
- `vm_hostnames` - Computer names
- `vm_private_ip_addresses` - Private IPs
- `vm_ids` - Azure resource IDs
- `generation_2_features` - Security feature status
- `monitoring_status` - Extension deployment status
- `security_features` - Security configuration details

## Examples

Check the `examples/` directory for:
- Basic single VM deployment
- Multi-VM production setup
- Confidential Computing configuration
- Syslog server configuration
- Custom monitoring setup

## Troubleshooting

### Common Issues

1. **SSH Connection Failed**
   - Verify SSH public key is correctly formatted
   - Check network security group rules
   - Ensure UFW allows SSH (port 22)

2. **Confidential VM Deployment Error**
   - Use DCasv5 or ECasv5 series VM sizes only
   - Ensure Generation 2 is enabled
   - Verify region supports Confidential VMs

3. **Custom Data Script Issues**
   - Check `/var/log/azure-ubuntu-setup.log` on the VM
   - Verify script syntax and permissions
   - Monitor cloud-init logs: `/var/log/cloud-init.log`

4. **Syslog Server Issues**
   - Check syslog service: `systemctl status rsyslog`
   - Verify listening ports: `netstat -ulnp | grep 514`
   - Check firewall rules: `ufw status`
   - View syslog logs: `tail -f /var/log/syslog`
   - Monitor remote logs: `ls -la /var/log/remote/`

### Useful Commands

```bash
# Check VM status
az vm list --resource-group "rg-name" --output table

# Connect via SSH
ssh -i ~/.ssh/private_key username@vm-ip

# Check setup script status on VM
sudo tail -f /var/log/azure-ubuntu-setup.log

# View VM extensions
az vm extension list --resource-group "rg-name" --vm-name "vm-name"

# Syslog server specific commands
ssh username@vm-ip 'sudo /usr/local/bin/syslog-monitor.sh'  # Check syslog status
ssh username@vm-ip 'sudo tail -f /var/log/remote/*/*.log'   # View incoming logs
ssh username@vm-ip 'df -h /var/log/remote'                 # Check disk usage
```

## Requirements

- Terraform >= 1.0
- Azure Provider ~> 3.116.0
- SSH public key for authentication
- Appropriate Azure permissions for VM creation

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review Azure documentation for Linux VMs
3. Validate Terraform configuration syntax
4. Check Azure activity logs for deployment errors

---

**Note**: This module is specifically designed for Ubuntu 24.04 LTS and follows enterprise security best practices. For Windows VMs, use the companion `virtual-machine` module.
