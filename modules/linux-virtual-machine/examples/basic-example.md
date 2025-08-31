# Basic Linux VM Example

This example demonstrates the simplest deployment of an Ubuntu 24.04 LTS virtual machine.

## Configuration

```hcl
module "basic_linux_vm" {
  source = "../../modules/linux-virtual-machine"

  # Basic Configuration
  region          = "uks"
  environment     = "dev"
  purpose         = "web"
  app_shortcode   = "TEST"
  instance        = "01"
  
  # Infrastructure
  rgname          = "rg-test-web-dev-01"
  location        = "UK South"
  subnetid        = "/subscriptions/xxx/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-hub/subnets/snet-vms"
  server_count    = 1
  size            = "Standard_B2ms"

  # SSH Authentication
  admin_username      = "ubuntu-admin"
  admin_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... your-public-key-here"

  # Optional: Custom tags
  tags = {
    Environment = "Development"
    Owner       = "developer@company.com"
    Purpose     = "Testing"
  }
}
```

## Outputs

```hcl
output "vm_name" {
  value = module.basic_linux_vm.vm_names[0]
}

output "vm_private_ip" {
  value = module.basic_linux_vm.vm_private_ip_addresses[0]
}

output "ssh_connection" {
  value = "ssh ubuntu-admin@${module.basic_linux_vm.vm_private_ip_addresses[0]}"
}
```

## What This Creates

- 1 Ubuntu 24.04 LTS VM with Generation 2 features
- Standard_B2ms size (2 vCPUs, 8 GB RAM)
- Network interface with dynamic private IP
- SSH key authentication enabled
- Password authentication disabled
- UFW firewall configured
- Basic monitoring and security setup

## Cost Estimate

- VM: ~£30-40/month (UK South)
- Storage: ~£5-10/month (StandardSSD_LRS)
- **Total**: ~£35-50/month

## Next Steps

1. Deploy with `terraform apply`
2. Connect via SSH using your private key
3. Verify Ubuntu setup completed: `sudo cat /var/log/azure-ubuntu-setup.log`
4. Check system status: `systemctl status`
