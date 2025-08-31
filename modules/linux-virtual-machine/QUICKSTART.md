# Linux Virtual Machine Module - Quick Start Guide

Get up and running with Ubuntu 24.04 LTS VMs in minutes!

## Prerequisites

- Terraform >= 1.0
- Azure CLI or service principal with VM creation permissions
- SSH key pair for authentication

## 1. Generate SSH Key (if needed)

```bash
# Generate new SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_vm_key -C "your-email@company.com"

# Your public key will be at ~/.ssh/azure_vm_key.pub
cat ~/.ssh/azure_vm_key.pub
```

## 2. Basic Deployment

Create `main.tf`:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-linux-vm-test-01"
  location = "UK South"
}

# Create virtual network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-test-01"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create subnet
resource "azurerm_subnet" "example" {
  name                 = "snet-vms"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Deploy Linux VM
module "linux_vm" {
  source = "./modules/linux-virtual-machine"

  # Basic Configuration
  region          = "uks"
  environment     = "dev"
  purpose         = "test"
  app_shortcode   = "DEMO"
  instance        = "01"
  
  # Infrastructure
  rgname          = azurerm_resource_group.example.name
  location        = azurerm_resource_group.example.location
  subnetid        = azurerm_subnet.example.id
  server_count    = 1
  size            = "Standard_B2ms"

  # SSH Authentication - REPLACE WITH YOUR PUBLIC KEY
  admin_username      = "demo-admin"
  admin_ssh_public_key = file("~/.ssh/azure_vm_key.pub")
}
```

## 3. Deploy

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply configuration
terraform apply

# Get VM IP address
terraform output
```

## 4. Connect

```bash
# SSH to your VM (replace IP with actual output)
ssh -i ~/.ssh/azure_vm_key demo-admin@10.0.1.4

# Check system status
systemctl status

# View setup log
sudo cat /var/log/azure-ubuntu-setup.log
```

## 5. Common Configurations

### Web Server VM

```hcl
module "web_server" {
  source = "./modules/linux-virtual-machine"

  region        = "uks"
  environment   = "dev"
  purpose       = "web"
  app_shortcode = "APP"
  
  rgname       = azurerm_resource_group.example.name
  location     = azurerm_resource_group.example.location
  subnetid     = azurerm_subnet.example.id
  server_count = 1
  size         = "Standard_D2s_v5"

  admin_username      = "web-admin"
  admin_ssh_public_key = file("~/.ssh/azure_vm_key.pub")

  # Custom web server setup
  custom_data = base64encode(file("./scripts/web-server-setup.sh"))
  
  tags = {
    Application = "WebServer"
    Owner      = "dev-team@company.com"
  }
}
```

### Database Server VM

```hcl
module "database_server" {
  source = "./modules/linux-virtual-machine"

  region        = "uks"
  environment   = "prd"
  purpose       = "db"
  app_shortcode = "CRM"
  
  rgname       = azurerm_resource_group.example.name
  location     = azurerm_resource_group.example.location
  subnetid     = azurerm_subnet.example.id
  server_count = 1
  size         = "Standard_E4s_v5"  # Memory optimized

  admin_username      = "db-admin"
  admin_ssh_public_key = file("~/.ssh/azure_vm_key.pub")

  # Enhanced security for database
  enable_encryption_at_host = true
  os_disk_storage_account_type = "Premium_LRS"
  
  tags = {
    Application = "Database"
    DataClass   = "Sensitive"
  }
}
```

### High Availability Setup

```hcl
module "ha_app_servers" {
  source = "./modules/linux-virtual-machine"

  region        = "uks"
  environment   = "prd"
  purpose       = "app"
  app_shortcode = "CRM"
  
  rgname       = azurerm_resource_group.example.name
  location     = azurerm_resource_group.example.location
  subnetid     = azurerm_subnet.example.id
  server_count = 3  # Multiple instances for HA
  size         = "Standard_D4s_v5"

  admin_username      = "app-admin"
  admin_ssh_public_key = file("~/.ssh/azure_vm_key.pub")

  # Production features
  enable_azure_monitor     = true
  enable_patch_management  = true
  enable_boot_diagnostics  = true
  
  stop_start_schedule = "Weekdays=06:00-22:00 / Weekends=0"
}
```

## 6. Useful Commands

### Terraform Operations
```bash
# View current state
terraform show

# List all resources
terraform state list

# Get specific output
terraform output vm_private_ip_addresses

# Destroy infrastructure
terraform destroy
```

### VM Management
```bash
# SSH with specific key
ssh -i ~/.ssh/azure_vm_key username@vm-ip

# Copy files to VM
scp -i ~/.ssh/azure_vm_key localfile.txt username@vm-ip:/home/username/

# Run commands remotely
ssh -i ~/.ssh/azure_vm_key username@vm-ip 'sudo systemctl status nginx'

# Port forwarding (e.g., for web apps)
ssh -i ~/.ssh/azure_vm_key -L 8080:localhost:80 username@vm-ip
```

### Azure CLI Commands
```bash
# List VMs
az vm list --resource-group "rg-linux-vm-test-01" --output table

# Start/Stop VMs
az vm start --resource-group "rg-linux-vm-test-01" --name "vm-name"
az vm stop --resource-group "rg-linux-vm-test-01" --name "vm-name"

# Get VM status
az vm get-instance-view --resource-group "rg-linux-vm-test-01" --name "vm-name"

# Update VM size
az vm resize --resource-group "rg-linux-vm-test-01" --name "vm-name" --size "Standard_D4s_v5"
```

## 7. Troubleshooting

### SSH Issues
```bash
# Check SSH service on VM (if you have console access)
sudo systemctl status ssh

# Test SSH key locally
ssh-keygen -y -f ~/.ssh/azure_vm_key

# Check SSH connection with verbose output
ssh -v -i ~/.ssh/azure_vm_key username@vm-ip
```

### VM Issues
```bash
# Check VM logs from Azure portal or CLI
az vm boot-diagnostics get-boot-log --resource-group "rg-name" --name "vm-name"

# View VM metrics
az monitor metrics list --resource "vm-resource-id" --metric "CPU"

# Check VM extensions
az vm extension list --resource-group "rg-name" --vm-name "vm-name"
```

### Terraform Issues
```bash
# Validate configuration
terraform validate

# Check formatting
terraform fmt

# Refresh state
terraform refresh

# Import existing resources
terraform import module.linux_vm.azurerm_linux_virtual_machine.linux-vm[0] /subscriptions/.../resourceGroups/.../providers/Microsoft.Compute/virtualMachines/vm-name
```

## 8. Next Steps

1. **Add monitoring**: Set up Log Analytics workspace and Data Collection Rules
2. **Configure backups**: Enable Azure Backup for your VMs
3. **Network security**: Add Network Security Groups and Application Security Groups
4. **Load balancing**: Add Azure Load Balancer for multiple VMs
5. **CI/CD**: Integrate with Azure DevOps or GitHub Actions
6. **Scaling**: Consider Virtual Machine Scale Sets for auto-scaling

## 9. Cost Optimization

- **VM Size**: Start with smaller sizes and scale up as needed
- **Storage**: Use Standard SSD unless you need Premium performance
- **Scheduling**: Use auto-start/stop for development environments
- **Reserved Instances**: Consider 1-3 year reservations for production
- **Spot Instances**: Use for development/testing workloads

## 10. Security Best Practices

- ✅ **Always use SSH keys** (never passwords)
- ✅ **Enable Generation 2** VMs for enhanced security
- ✅ **Use latest Ubuntu LTS** (24.04)
- ✅ **Configure UFW firewall** properly
- ✅ **Enable Azure Monitor** for logging
- ✅ **Keep systems updated** with automatic patching
- ✅ **Use NSGs** for network-level security
- ✅ **Regular backups** and disaster recovery testing

## Support & Documentation

- **Module Documentation**: See `README.md` for full details
- **Examples**: Check `examples/` directory for more configurations
- **Azure Documentation**: [Azure Linux VMs](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/)
- **Ubuntu Documentation**: [Ubuntu 24.04 LTS](https://ubuntu.com/server/docs)

---

🎉 **You're all set!** Your Ubuntu 24.04 LTS VM is ready for your applications.

For production deployments, review the production example in `examples/production-example.md`.
