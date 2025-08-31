# Confidential Computing Linux VM Example

This example demonstrates deploying Ubuntu 24.04 LTS with Azure Confidential Computing capabilities for sensitive workloads requiring hardware-level encryption and isolation.

## Configuration

```hcl
# Confidential Linux VM with DCasv5 series
module "confidential_linux_vm" {
  source = "../../modules/linux-virtual-machine"

  # Confidential VM Configuration
  region          = "uks"
  environment     = "prd"
  purpose         = "secure"
  app_shortcode   = "HSM"
  instance        = "01"
  
  # Infrastructure
  rgname          = "rg-hsm-secure-prd-01"
  location        = "UK South"
  subnetid        = var.subnet_id
  server_count    = 1
  
  # Confidential Computing (REQUIRED: DCasv5 or ECasv5 series)
  size                    = "Standard_DC4as_v5"  # 4 vCPUs, 16 GB RAM with CVM support
  enable_confidential_vm  = true
  enable_generation_2     = true  # Required for Confidential VMs
  security_encryption_type = "VMGuestStateOnly"

  # Enhanced Security Configuration
  enable_secure_boot       = true
  enable_vtpm             = true
  enable_encryption_at_host = true
  os_disk_storage_account_type = "Premium_LRS"  # Recommended for CVM

  # SSH Configuration
  admin_username              = "secure-admin"
  admin_ssh_public_key        = var.ssh_public_key
  disable_password_authentication = true

  # Monitoring (with security considerations)
  enable_azure_monitor        = true
  enable_dependency_agent     = false  # Disable for high-security environments
  enable_guest_configuration  = true
  enable_boot_diagnostics     = true
  data_collection_rule_id     = var.secure_dcr_id

  # Security Hardening
  custom_data = base64encode(templatefile("${path.module}/scripts/confidential-vm-setup.sh", {
    admin_username = "secure-admin"
    timezone       = "Europe/London"
  }))
  
  # Security-focused Tagging
  department    = "Security"
  project       = "HSM Platform"
  cost_center   = "SEC-001"
  rfc           = "RFC-2024-CVM-001"
  update_ring   = "Priority"
  
  tags = {
    Application       = "HSM"
    SecurityLevel     = "Confidential"
    DataClassification = "Highly Confidential"
    Compliance        = "SOC2,ISO27001"
    Owner            = "security-team@company.com"
    EncryptionLevel  = "Hardware"
    Monitoring       = "Restricted"
  }
}

# Optional: Customer-managed disk encryption set for DiskWithVMGuestState
resource "azurerm_disk_encryption_set" "confidential_vm_des" {
  name                = "des-confidential-vm-prd"
  resource_group_name = "rg-hsm-secure-prd-01"
  location           = "UK South"
  key_vault_key_id   = var.key_vault_key_id

  identity {
    type = "SystemAssigned"
  }

  tags = module.confidential_linux_vm.vm_tags
}

# Example with DiskWithVMGuestState encryption
module "confidential_linux_vm_with_disk_encryption" {
  source = "../../modules/linux-virtual-machine"

  # Same configuration as above, but with disk encryption
  region          = "uks"
  environment     = "prd"
  purpose         = "secure"
  app_shortcode   = "HSM"
  instance        = "02"
  
  rgname          = "rg-hsm-secure-prd-01"
  location        = "UK South"
  subnetid        = var.subnet_id
  server_count    = 1
  size            = "Standard_DC8as_v5"  # Larger for performance

  # Confidential VM with customer-managed disk encryption
  enable_confidential_vm  = true
  enable_generation_2     = true
  security_encryption_type = "DiskWithVMGuestState"
  confidential_vm_disk_encryption_set_id = azurerm_disk_encryption_set.confidential_vm_des.id

  # ... rest of configuration same as above
  admin_username      = "secure-admin"
  admin_ssh_public_key = var.ssh_public_key
  
  tags = {
    Application       = "HSM"
    SecurityLevel     = "Confidential"
    EncryptionType   = "CustomerManaged"
    Instance         = "02"
  }
}
```

## Confidential VM Setup Script

Create `scripts/confidential-vm-setup.sh`:

```bash
#!/bin/bash

# Confidential VM Security Hardening Script for Ubuntu 24.04
set -e

# Log everything to secure location
exec > >(tee /var/log/confidential-vm-setup.log)
exec 2>&1

echo "Starting Confidential VM security hardening at $(date)"

# Base Ubuntu setup first
# ... include standard ubuntu-setup.sh content ...

echo "Applying Confidential VM specific hardening..."

# Verify we're running on a Confidential VM
if [ -f /sys/firmware/efi/efivars/ConfidentialComputing-* ]; then
    echo "✓ Confidential Computing verified"
else
    echo "⚠ Warning: Confidential Computing features not detected"
fi

# Additional security hardening for CVM
echo "Implementing additional security measures..."

# Disable unused services
systemctl disable bluetooth
systemctl disable cups
systemctl disable avahi-daemon

# Enhanced SSH hardening
cat >> /etc/ssh/sshd_config << EOF

# Confidential VM SSH Hardening
Protocol 2
LoginGraceTime 30
MaxAuthTries 3
MaxSessions 2
ClientAliveInterval 300
ClientAliveCountMax 0
AllowUsers ${admin_username}
DenyUsers root
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no
GatewayPorts no
PermitTunnel no
EOF

# Restart SSH with new configuration
systemctl restart ssh

# Configure stricter firewall rules
ufw --force reset
ufw default deny incoming
ufw default deny outgoing
ufw default deny forward

# Allow only essential outbound connections
ufw allow out 53    # DNS
ufw allow out 80    # HTTP for updates
ufw allow out 443   # HTTPS for updates
ufw allow out 123   # NTP

# Allow SSH inbound
ufw allow in 22/tcp

# Enable firewall
ufw --force enable

# Configure auditd for security monitoring
apt-get install -y auditd audispd-plugins
systemctl enable auditd

# Create audit rules for sensitive operations
cat > /etc/audit/rules.d/confidential-vm.rules << EOF
# Monitor file access
-a always,exit -F arch=b64 -S openat -F dir=/etc -F perm=wa -k etc_changes
-a always,exit -F arch=b64 -S openat -F dir=/boot -F perm=wa -k boot_changes

# Monitor privilege escalation
-a always,exit -F arch=b64 -S setuid -S setgid -S setreuid -S setregid -k privilege_escalation

# Monitor network connections
-a always,exit -F arch=b64 -S socket -F a0=2 -k network_connect

# Monitor process execution
-a always,exit -F arch=b64 -S execve -k process_execution
EOF

# Restart auditd
systemctl restart auditd

# Configure sysctl for security
cat > /etc/sysctl.d/99-confidential-vm.conf << EOF
# Network security
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1

# Kernel security
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 2
fs.suid_dumpable = 0
EOF

sysctl -p /etc/sysctl.d/99-confidential-vm.conf

# Set up log monitoring
cat > /etc/logrotate.d/confidential-vm << EOF
/var/log/confidential-vm-setup.log {
    weekly
    rotate 52
    compress
    delaycompress
    missingok
    notifempty
    create 600 root root
}
EOF

# Create security validation script
cat > /usr/local/bin/validate-confidential-vm.sh << 'EOF'
#!/bin/bash

echo "Confidential VM Security Validation Report"
echo "=========================================="
echo "Date: $(date)"
echo ""

# Check Confidential Computing
if [ -f /sys/firmware/efi/efivars/ConfidentialComputing-* ]; then
    echo "✓ Confidential Computing: ENABLED"
else
    echo "✗ Confidential Computing: NOT DETECTED"
fi

# Check Secure Boot
if [ "$(bootctl status 2>/dev/null | grep -i 'secure boot' | grep -i enabled)" ]; then
    echo "✓ Secure Boot: ENABLED"
else
    echo "✗ Secure Boot: DISABLED"
fi

# Check vTPM
if [ -d /sys/class/tpm/tpm0 ]; then
    echo "✓ vTPM: AVAILABLE"
else
    echo "✗ vTPM: NOT AVAILABLE"
fi

# Check SSH configuration
if grep -q "PasswordAuthentication no" /etc/ssh/sshd_config; then
    echo "✓ SSH: Password authentication disabled"
else
    echo "✗ SSH: Password authentication enabled"
fi

# Check firewall
if ufw status | grep -q "Status: active"; then
    echo "✓ Firewall: ACTIVE"
else
    echo "✗ Firewall: INACTIVE"
fi

# Check audit daemon
if systemctl is-active --quiet auditd; then
    echo "✓ Audit: RUNNING"
else
    echo "✗ Audit: NOT RUNNING"
fi

echo ""
echo "Security validation completed."
EOF

chmod +x /usr/local/bin/validate-confidential-vm.sh

# Run initial validation
/usr/local/bin/validate-confidential-vm.sh

# Create completion marker
touch /var/log/confidential-vm-setup-complete

echo "Confidential VM security hardening completed successfully at $(date)"
echo "Run 'sudo /usr/local/bin/validate-confidential-vm.sh' to verify security status"
```

## Variables

```hcl
variable "subnet_id" {
  description = "Subnet ID for the Confidential VM"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for secure access"
  type        = string
}

variable "secure_dcr_id" {
  description = "Data Collection Rule ID for security monitoring"
  type        = string
}

variable "key_vault_key_id" {
  description = "Key Vault key ID for disk encryption (optional)"
  type        = string
  default     = null
}
```

## Outputs

```hcl
output "confidential_vm_status" {
  value = {
    vm_name              = module.confidential_linux_vm.vm_names[0]
    vm_size              = module.confidential_linux_vm.vm_sizes[0]
    private_ip           = module.confidential_linux_vm.vm_private_ip_addresses[0]
    confidential_features = module.confidential_linux_vm.generation_2_features
    security_config      = module.confidential_linux_vm.security_features
  }
}

output "security_validation_command" {
  value = "ssh secure-admin@${module.confidential_linux_vm.vm_private_ip_addresses[0]} 'sudo /usr/local/bin/validate-confidential-vm.sh'"
}

output "disk_encryption_set_id" {
  value = azurerm_disk_encryption_set.confidential_vm_des.id
}
```

## What This Creates

### Confidential Computing Features
- **Hardware-level encryption** using AMD SEV-SNP or Intel TDX
- **Encrypted memory** protecting data during processing
- **Attestation support** for verifying VM integrity
- **Secure key management** with vTPM integration

### Enhanced Security
- **Generation 2 VM** with UEFI Secure Boot
- **vTPM** for cryptographic operations
- **Encrypted disks** with optional customer-managed keys
- **Network isolation** with strict firewall rules
- **Audit logging** for security monitoring

### Compliance Features
- **SOC 2 compliance** ready configuration
- **ISO 27001** security controls
- **Detailed audit trails** for all operations
- **Security validation** scripts and reporting

## Confidential VM Size Compatibility

### DCasv5-series (AMD-based)
| Size | vCPUs | RAM | Max Disks | Network Performance |
|------|-------|-----|-----------|-------------------|
| Standard_DC2as_v5 | 2 | 8 GB | 4 | Moderate |
| Standard_DC4as_v5 | 4 | 16 GB | 8 | Moderate |
| Standard_DC8as_v5 | 8 | 32 GB | 16 | High |
| Standard_DC16as_v5 | 16 | 64 GB | 32 | High |

### ECasv5-series (Memory Optimized)
| Size | vCPUs | RAM | Max Disks | Network Performance |
|------|-------|-----|-----------|-------------------|
| Standard_EC2as_v5 | 2 | 16 GB | 4 | Moderate |
| Standard_EC4as_v5 | 4 | 32 GB | 8 | Moderate |
| Standard_EC8as_v5 | 8 | 64 GB | 16 | High |

## Security Validation

After deployment, validate the Confidential VM setup:

```bash
# Connect to the VM
ssh secure-admin@<vm-ip>

# Run security validation
sudo /usr/local/bin/validate-confidential-vm.sh

# Check Confidential Computing status
ls /sys/firmware/efi/efivars/ConfidentialComputing-*

# Verify vTPM
ls /sys/class/tpm/

# Check Secure Boot status
bootctl status

# Verify audit logging
sudo auditctl -l

# Check firewall status
sudo ufw status verbose
```

## Cost Considerations

Confidential VMs have premium pricing:

- **Standard_DC4as_v5**: ~£200-250/month (vs ~£120 for regular D4s_v5)
- **Premium Storage**: ~£15-20/month
- **Customer-managed encryption**: +~£10-15/month
- **Enhanced monitoring**: ~£5-10/month
- **Total**: ~£230-295/month

## Use Cases

Perfect for:
- 🔒 **Sensitive data processing** (PII, financial data)
- 🏛️ **Regulatory compliance** (GDPR, HIPAA, SOX)
- 🔐 **Cryptographic operations** (key management, signing)
- 🏢 **Multi-tenant isolation** (SaaS platforms)
- 🛡️ **Zero-trust architectures** (hardware verification)

## Important Notes

1. **VM Size Requirement**: Only DCasv5 and ECasv5 series support Confidential VMs
2. **Generation 2 Required**: Confidential VMs must use Generation 2
3. **Regional Availability**: Not all Azure regions support Confidential VMs
4. **Performance Impact**: ~5-10% performance overhead for encryption
5. **Network Isolation**: Enhanced security may impact network connectivity
6. **Monitoring Limitations**: Some monitoring features may be restricted

## Troubleshooting

### Common Issues

1. **Deployment Error: VM size not supported**
   - Solution: Use DCasv5 or ECasv5 series sizes only

2. **Confidential features not detected**
   - Check: Verify region supports Confidential VMs
   - Check: Ensure Generation 2 is enabled

3. **SSH connection issues**
   - Check: Firewall rules (very restrictive by default)
   - Check: Network security groups
   - Check: SSH key format and permissions

4. **Performance concerns**
   - Consider: Larger VM sizes to offset encryption overhead
   - Monitor: CPU and memory utilization
   - Optimize: Application for Confidential Computing environment
