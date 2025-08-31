# Syslog Server Linux VM Example

This example demonstrates deploying an Ubuntu 24.04 LTS virtual machine configured as a centralized syslog server for network infrastructure and application logging.

## Configuration

```hcl
# Data sources for existing resources
data "azurerm_subnet" "syslog_subnet" {
  name                 = "snet-logging"
  virtual_network_name = "vnet-hub"
  resource_group_name  = "rg-network-hub"
}

data "azurerm_monitor_data_collection_rule" "logging_dcr" {
  name                = "dcr-infrastructure-logging"
  resource_group_name = "rg-monitoring-hub"
}

# Network Security Group for Syslog Server
resource "azurerm_network_security_group" "syslog_nsg" {
  name                = "nsg-syslog-server"
  location            = "UK South"
  resource_group_name = "rg-logging-hub-prd-01"

  # SSH access
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }

  # Syslog UDP
  security_rule {
    name                       = "Syslog-UDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "514"
    source_address_prefixes    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    destination_address_prefix = "*"
  }

  # Syslog TCP
  security_rule {
    name                       = "Syslog-TCP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "514"
    source_address_prefixes    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    destination_address_prefix = "*"
  }

  # Syslog TLS
  security_rule {
    name                       = "Syslog-TLS"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6514"
    source_address_prefixes    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    destination_address_prefix = "*"
  }

  tags = {
    Purpose = "SyslogServer"
    Environment = "Production"
  }
}

# Subnet association
resource "azurerm_subnet_network_security_group_association" "syslog_nsg_association" {
  subnet_id                 = data.azurerm_subnet.syslog_subnet.id
  network_security_group_id = azurerm_network_security_group.syslog_nsg.id
}

# Syslog Server VM
module "syslog_server" {
  source = "../../modules/linux-virtual-machine"

  # Basic Configuration
  region          = "uks"
  environment     = "prd"
  purpose         = "syslog"
  app_shortcode   = "LOG"
  instance        = "01"
  
  # Infrastructure
  rgname          = "rg-logging-hub-prd-01"
  location        = "UK South"
  subnetid        = data.azurerm_subnet.syslog_subnet.id
  server_count    = 1
  size            = "Standard_D4s_v5"  # 4 vCPUs, 16 GB RAM for log processing

  # VM Configuration
  enable_generation_2      = true
  enable_secure_boot       = true
  enable_vtpm             = true
  enable_encryption_at_host = true
  os_disk_storage_account_type = "Premium_LRS"  # Fast storage for logs

  # SSH Configuration
  admin_username              = "syslog-admin"
  admin_ssh_public_key        = var.ssh_public_key
  disable_password_authentication = true

  # Syslog Server Configuration
  enable_syslog_server     = true
  syslog_port             = 514
  syslog_protocol         = "both"  # UDP and TCP
  enable_syslog_tls       = true    # Enable TLS on port 6514
  syslog_allowed_networks = [
    "10.0.0.0/8",      # Corporate network
    "172.16.0.0/12",   # Azure VNets
    "192.168.0.0/16"   # Branch offices
  ]
  syslog_log_retention_days = 90    # 3 months retention
  syslog_max_log_size      = "500M" # 500MB max file size
  
  # Custom syslog filtering rules
  syslog_custom_rules = [
    # Separate critical messages
    ":syslogtag, contains, \"ERROR\" /var/log/remote/critical/error.log",
    ":syslogtag, contains, \"CRITICAL\" /var/log/remote/critical/critical.log",
    # Separate security logs
    ":programname, contains, \"ssh\" /var/log/remote/security/ssh.log",
    ":programname, contains, \"sudo\" /var/log/remote/security/sudo.log",
    # Network device logs
    ":fromhost-ip, startswith, \"192.168.1.\" /var/log/remote/network/switches.log",
    ":fromhost-ip, startswith, \"192.168.2.\" /var/log/remote/network/routers.log"
  ]

  # Monitoring & Management
  enable_azure_monitor        = true
  enable_dependency_agent     = true
  enable_guest_configuration  = true
  enable_boot_diagnostics     = true
  data_collection_rule_id     = data.azurerm_monitor_data_collection_rule.logging_dcr.id

  # Enhanced monitoring for log server
  enable_patch_management     = true
  timezone                   = "Europe/London"
  
  # Production Tagging
  department    = "Infrastructure"
  project       = "Centralized Logging"
  cost_center   = "IT-OPS-001"
  rfc           = "RFC-2024-SYSLOG-001"
  update_ring   = "Standard"  # Not priority to avoid disrupting logging
  stop_start_schedule = "24x7"  # Always on for logging
  
  tags = {
    Application    = "SyslogServer"
    Tier          = "Infrastructure"
    Function      = "Logging"
    Criticality   = "High"
    Owner         = "infrastructure-team@company.com"
    DataRetention = "90days"
    Protocol      = "Syslog"
    Monitoring    = "Enhanced"
  }
}

# Additional data disk for log storage
resource "azurerm_managed_disk" "syslog_data_disk" {
  name                 = "disk-syslog-data-prd-01"
  location             = "UK South"
  resource_group_name  = "rg-logging-hub-prd-01"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 1024  # 1TB for log storage

  tags = module.syslog_server.vm_tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "syslog_data_attachment" {
  managed_disk_id    = azurerm_managed_disk.syslog_data_disk.id
  virtual_machine_id = module.syslog_server.vm_ids[0]
  lun                = "0"
  caching            = "ReadWrite"
}

# Log Analytics Workspace for Azure integration
resource "azurerm_log_analytics_workspace" "syslog_analytics" {
  name                = "law-syslog-hub-prd-01"
  location            = "UK South"
  resource_group_name = "rg-logging-hub-prd-01"
  sku                = "PerGB2018"
  retention_in_days   = 90

  tags = module.syslog_server.vm_tags
}

# Azure Monitor Data Collection Rule for syslog forwarding
resource "azurerm_monitor_data_collection_rule" "syslog_dcr" {
  name                = "dcr-syslog-forwarding"
  resource_group_name = "rg-logging-hub-prd-01"
  location           = "UK South"

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.syslog_analytics.id
      name                 = "syslog-destination"
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["syslog-destination"]
  }

  data_sources {
    syslog {
      facility_names = [
        "auth",
        "authpriv", 
        "cron",
        "daemon",
        "kern",
        "local0",
        "local1",
        "local2",
        "local3",
        "local4",
        "local5",
        "local6",
        "local7",
        "mail",
        "news",
        "syslog",
        "user",
        "uucp"
      ]
      log_levels = [
        "Debug",
        "Info",
        "Notice", 
        "Warning",
        "Error",
        "Critical",
        "Alert",
        "Emergency"
      ]
      name = "syslog-datasource"
    }
  }

  tags = module.syslog_server.vm_tags
}
```

## Data Disk Setup Script

Create `scripts/setup-data-disk.sh` for additional log storage:

```bash
#!/bin/bash

# Setup additional data disk for syslog storage
echo "Setting up data disk for syslog storage..."

# Wait for disk to be available
sleep 30

# Check if disk exists
if [ -b /dev/sdc ]; then
    # Partition the disk
    parted /dev/sdc --script mklabel gpt
    parted /dev/sdc --script mkpart primary ext4 0% 100%
    
    # Format the partition
    mkfs.ext4 /dev/sdc1
    
    # Create mount point
    mkdir -p /var/log/remote-storage
    
    # Get UUID
    UUID=$(blkid -s UUID -o value /dev/sdc1)
    
    # Add to fstab
    echo "UUID=$UUID /var/log/remote-storage ext4 defaults,nofail 0 2" >> /etc/fstab
    
    # Mount the disk
    mount -a
    
    # Set permissions
    chown syslog:adm /var/log/remote-storage
    chmod 755 /var/log/remote-storage
    
    # Update rsyslog configuration to use new location
    sed -i 's|/var/log/remote|/var/log/remote-storage|g' /etc/rsyslog.d/50-remote.conf
    
    # Restart rsyslog
    systemctl restart rsyslog
    
    echo "Data disk setup completed: /var/log/remote-storage"
else
    echo "Data disk not found, using default location"
fi
```

## Variables

```hcl
variable "ssh_public_key" {
  description = "SSH public key for syslog server access"
  type        = string
}
```

## Outputs

```hcl
output "syslog_server_details" {
  value = {
    vm_name              = module.syslog_server.vm_names[0]
    private_ip           = module.syslog_server.vm_private_ip_addresses[0]
    syslog_configuration = module.syslog_server.syslog_server_info
  }
}

output "syslog_endpoints" {
  description = "Syslog server connection details"
  value = {
    udp_endpoint = "${module.syslog_server.vm_private_ip_addresses[0]}:514"
    tcp_endpoint = "${module.syslog_server.vm_private_ip_addresses[0]}:514"
    tls_endpoint = "${module.syslog_server.vm_private_ip_addresses[0]}:6514"
  }
}

output "log_analytics_workspace" {
  value = {
    id           = azurerm_log_analytics_workspace.syslog_analytics.id
    workspace_id = azurerm_log_analytics_workspace.syslog_analytics.workspace_id
  }
}

output "monitoring_commands" {
  description = "Useful commands for managing the syslog server"
  value = {
    ssh_connection     = "ssh syslog-admin@${module.syslog_server.vm_private_ip_addresses[0]}"
    monitor_status     = "ssh syslog-admin@${module.syslog_server.vm_private_ip_addresses[0]} 'sudo /usr/local/bin/syslog-monitor.sh'"
    view_remote_logs   = "ssh syslog-admin@${module.syslog_server.vm_private_ip_addresses[0]} 'sudo ls -la /var/log/remote/'"
    check_disk_usage   = "ssh syslog-admin@${module.syslog_server.vm_private_ip_addresses[0]} 'df -h /var/log/remote'"
  }
}
```

## What This Creates

### Syslog Server Features
- **Multi-protocol support**: UDP/TCP on port 514, TLS on port 6514
- **Network filtering**: Only accepts logs from specified CIDR ranges
- **Log organization**: Separates logs by hostname and program
- **Log rotation**: Automatic rotation with configurable retention
- **TLS encryption**: Self-signed certificates for secure transport
- **Custom filtering**: Flexible rules for log categorization

### Storage & Performance  
- **Premium SSD**: Fast storage for OS and logs
- **Additional data disk**: 1TB dedicated storage for logs
- **Log rotation**: Prevents disk space issues
- **Performance monitoring**: Built-in monitoring scripts

### Security & Compliance
- **Network Security Groups**: Restricted access to syslog ports
- **Generation 2 VM**: Enhanced security features
- **SSH key authentication**: No password access
- **Firewall rules**: UFW configured for syslog ports
- **TLS encryption**: Secure log transmission

### Integration & Monitoring
- **Azure Monitor**: Integration with Log Analytics
- **Data Collection Rules**: Forward logs to Azure
- **Custom monitoring**: Hourly status checks
- **Boot diagnostics**: VM troubleshooting support

## Client Configuration Examples

### Linux Client (rsyslog)
```bash
# Configure client to send logs to syslog server
echo "*.* @@10.0.1.100:514" >> /etc/rsyslog.conf
systemctl restart rsyslog

# For TLS (secure):
echo "*.* @@10.0.1.100:6514" >> /etc/rsyslog.conf
```

### Network Device Configuration
```bash
# Cisco example
logging host 10.0.1.100
logging trap informational

# Fortinet example  
config log syslogd setting
    set status enable
    set server "10.0.1.100"
    set port 514
end
```

### Windows Event Forwarding
```powershell
# Configure Windows to forward events
wecutil cs subscription.xml

# Where subscription.xml contains syslog forwarding config
```

## Monitoring & Maintenance

### Daily Operations
```bash
# Connect to syslog server
ssh syslog-admin@<syslog-server-ip>

# Check syslog status
sudo /usr/local/bin/syslog-monitor.sh

# View incoming logs in real-time
sudo tail -f /var/log/remote/*/*.log

# Check disk usage
df -h /var/log/remote-storage

# View rsyslog service status
systemctl status rsyslog
```

### Log Analysis
```bash
# Find critical errors across all hosts
grep -r "CRITICAL\|ERROR" /var/log/remote-storage/

# View logs from specific host
ls /var/log/remote-storage/hostname/

# Count log entries by host
find /var/log/remote-storage -name "*.log" -exec wc -l {} + | sort -n

# Check log file sizes
du -sh /var/log/remote-storage/*
```

### Troubleshooting

1. **No logs being received**
   - Check firewall: `sudo ufw status`
   - Verify rsyslog is listening: `netstat -ulnp | grep 514`
   - Check rsyslog errors: `journalctl -u rsyslog`

2. **Disk space issues**
   - Check disk usage: `df -h`
   - Review log rotation: `logrotate -d /etc/logrotate.d/remote-syslog`
   - Manually rotate: `logrotate -f /etc/logrotate.d/remote-syslog`

3. **Performance issues**
   - Monitor CPU/memory: `htop`
   - Check I/O: `iotop`
   - Review rsyslog buffers in `/etc/rsyslog.conf`

## Cost Considerations

- **VM (Standard_D4s_v5)**: ~£150-200/month
- **Premium SSD OS disk (128GB)**: ~£15-20/month  
- **Premium SSD data disk (1TB)**: ~£120-150/month
- **Log Analytics Workspace**: ~£10-50/month (depending on volume)
- **Network egress**: Variable based on log volume
- **Total**: ~£295-420/month

## Use Cases

Perfect for:
- 🏢 **Enterprise logging**: Centralized collection from all infrastructure
- 🔒 **Security monitoring**: SIEM integration and security log analysis
- 📊 **Compliance**: Audit trail and regulatory compliance (SOX, PCI-DSS)
- 🌐 **Network monitoring**: Router, switch, and firewall log collection
- 🔍 **Troubleshooting**: Centralized view for incident response
- 📈 **Analytics**: Log analysis and performance monitoring

This syslog server provides enterprise-grade centralized logging with security, performance, and compliance features built-in!
