# Production Linux VM Example

This example shows a production-ready deployment with full monitoring, security features, and high availability.

## Configuration

```hcl
# Data sources for existing resources
data "azurerm_subnet" "vm_subnet" {
  name                 = "snet-prod-vms"
  virtual_network_name = "vnet-prod-hub"
  resource_group_name  = "rg-network-prod"
}

data "azurerm_monitor_data_collection_rule" "vm_dcr" {
  name                = "dcr-vm-monitoring-prod"
  resource_group_name = "rg-monitoring-prod"
}

# Production Linux VMs
module "production_linux_vms" {
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
  subnetid        = data.azurerm_subnet.vm_subnet.id
  server_count    = 3  # Load balanced application servers
  size            = "Standard_D4s_v5"  # 4 vCPUs, 16 GB RAM

  # Performance & Security
  enable_generation_2      = true
  enable_secure_boot       = true
  enable_vtpm             = true
  enable_encryption_at_host = true
  os_disk_storage_account_type = "Premium_LRS"

  # SSH Configuration
  admin_username              = "crm-admin"
  admin_ssh_public_key        = var.ssh_public_key
  disable_password_authentication = true

  # Monitoring & Management
  enable_azure_monitor        = true
  enable_dependency_agent     = true
  enable_guest_configuration  = true
  enable_boot_diagnostics     = true
  data_collection_rule_id     = data.azurerm_monitor_data_collection_rule.vm_dcr.id

  # Patch Management
  enable_patch_management     = true

  # Custom Setup
  timezone = "Europe/London"
  custom_data = base64encode(templatefile("${path.module}/scripts/crm-app-setup.sh", {
    app_version    = var.crm_app_version
    database_url   = var.database_connection_string
    redis_url      = var.redis_connection_string
    admin_username = "crm-admin"
    timezone       = "Europe/London"
  }))
  
  # Production Tagging
  department    = "Engineering"
  project       = "CRM Platform"
  cost_center   = "TECH-001"
  rfc           = "RFC-2024-CRM-001"
  update_ring   = "Priority"
  stop_start_schedule = "Weekdays=06:00-22:00 / Weekends=0"  # Business hours
  
  tags = {
    Application     = "CRM"
    Tier           = "Application"
    Owner          = "platform-team@company.com"
    DataClass      = "Internal"
    BackupRequired = "Yes"
    Monitoring     = "Enhanced"
  }
}

# Load Balancer for the application servers
resource "azurerm_lb" "crm_app_lb" {
  name                = "lb-crm-app-prd-01"
  location            = "UK South"
  resource_group_name = "rg-crm-app-prd-01"
  sku                = "Standard"

  frontend_ip_configuration {
    name                 = "internal"
    subnet_id           = data.azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = module.production_linux_vms.vm_tags
}

resource "azurerm_lb_backend_address_pool" "crm_app_pool" {
  loadbalancer_id = azurerm_lb.crm_app_lb.id
  name            = "crm-app-pool"
}

resource "azurerm_lb_backend_address_pool_address" "crm_app_addresses" {
  count                   = length(module.production_linux_vms.vm_private_ip_addresses)
  name                    = "crm-app-${count.index + 1}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.crm_app_pool.id
  virtual_network_id      = data.azurerm_subnet.vm_subnet.virtual_network_id
  ip_address             = module.production_linux_vms.vm_private_ip_addresses[count.index]
}

# Load balancer health probe
resource "azurerm_lb_probe" "crm_app_probe" {
  loadbalancer_id = azurerm_lb.crm_app_lb.id
  name            = "http-health"
  port            = 8080
  protocol        = "Http"
  request_path    = "/health"
}

# Load balancer rule
resource "azurerm_lb_rule" "crm_app_rule" {
  loadbalancer_id                = azurerm_lb.crm_app_lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8080
  frontend_ip_configuration_name = "internal"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.crm_app_pool.id]
  probe_id                       = azurerm_lb_probe.crm_app_probe.id
}
```

## Custom Application Setup Script

Create `scripts/crm-app-setup.sh`:

```bash
#!/bin/bash

# CRM Application Setup Script for Ubuntu 24.04
set -e

# Source the base Ubuntu setup
source /dev/stdin << 'EOF'
# Include the standard ubuntu-setup.sh content here
# ... (standard setup from the module)
EOF

echo "Starting CRM application setup..."

# Install Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
apt-get install -y nodejs

# Install PM2 for process management
npm install -g pm2

# Create application user
useradd -m -s /bin/bash crmapp
usermod -aG sudo crmapp

# Create application directory
mkdir -p /opt/crm-app
chown crmapp:crmapp /opt/crm-app

# Configure application environment
cat > /opt/crm-app/.env << EOL
NODE_ENV=production
PORT=8080
DATABASE_URL=${database_url}
REDIS_URL=${redis_url}
APP_VERSION=${app_version}
EOL

chown crmapp:crmapp /opt/crm-app/.env
chmod 600 /opt/crm-app/.env

# Configure PM2 ecosystem
cat > /opt/crm-app/ecosystem.config.js << EOL
module.exports = {
  apps: [{
    name: 'crm-app',
    script: './app.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 8080
    },
    log_file: '/var/log/crm-app.log',
    error_file: '/var/log/crm-app-error.log',
    out_file: '/var/log/crm-app-out.log',
    max_memory_restart: '1G'
  }]
}
EOL

chown crmapp:crmapp /opt/crm-app/ecosystem.config.js

# Setup PM2 startup
sudo -u crmapp pm2 startup systemd -u crmapp --hp /home/crmapp

echo "CRM application setup completed!"
```

## Variables

```hcl
variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "crm_app_version" {
  description = "CRM application version to deploy"
  type        = string
  default     = "v1.2.3"
}

variable "database_connection_string" {
  description = "Database connection string"
  type        = string
  sensitive   = true
}

variable "redis_connection_string" {
  description = "Redis connection string"
  type        = string
  sensitive   = true
}
```

## Outputs

```hcl
output "vm_details" {
  value = {
    names        = module.production_linux_vms.vm_names
    private_ips  = module.production_linux_vms.vm_private_ip_addresses
    hostnames    = module.production_linux_vms.vm_hostnames
  }
}

output "load_balancer_ip" {
  value = azurerm_lb.crm_app_lb.frontend_ip_configuration[0].private_ip_address
}

output "monitoring_status" {
  value = module.production_linux_vms.monitoring_status
}

output "security_features" {
  value = module.production_linux_vms.security_features
}

output "ssh_connections" {
  value = [
    for ip in module.production_linux_vms.vm_private_ip_addresses :
    "ssh crm-admin@${ip}"
  ]
}
```

## What This Creates

### Infrastructure
- 3 Ubuntu 24.04 LTS VMs (High Availability)
- Premium SSD storage for performance
- Load balancer with health probes
- Enhanced monitoring and logging
- Network security and firewall rules

### Security Features
- Generation 2 VMs with Secure Boot and vTPM
- Encryption at host enabled
- SSH key authentication only
- UFW firewall configured
- Guest Configuration for compliance

### Monitoring
- Azure Monitor Agent with custom DCR
- Dependency Agent for application mapping
- Boot diagnostics enabled
- Custom application logging

### Application Setup
- Node.js 20 LTS runtime
- PM2 process manager
- Application user and environment
- Health check endpoint
- Log management

## Deployment Steps

1. **Prepare Environment**
   ```bash
   # Set up variables
   export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_rsa.pub)"
   export TF_VAR_database_connection_string="postgresql://..."
   export TF_VAR_redis_connection_string="redis://..."
   ```

2. **Deploy Infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Verify Deployment**
   ```bash
   # Test SSH access
   ssh crm-admin@<vm-ip>
   
   # Check application status
   sudo -u crmapp pm2 status
   
   # Test health endpoint
   curl http://<load-balancer-ip>/health
   ```

## Cost Estimate (3 VMs)

- VMs (3x Standard_D4s_v5): ~£300-400/month
- Premium Storage (3x 128GB): ~£30-40/month
- Load Balancer: ~£15-20/month
- **Total**: ~£345-460/month

## Best Practices Implemented

- ✅ High availability with multiple instances
- ✅ Load balancing for traffic distribution
- ✅ Enhanced security with Generation 2 features
- ✅ Comprehensive monitoring and logging
- ✅ Automated patching and updates
- ✅ Proper application user separation
- ✅ Environment-specific configuration
- ✅ Health checks and monitoring
- ✅ Business hours scheduling
