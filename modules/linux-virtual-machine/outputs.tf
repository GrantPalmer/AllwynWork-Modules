output "admin_username" {
  description = "The admin username for the VMs"
  value       = var.admin_username
}

output "vm_names" {
  description = "Names of the created virtual machines"
  value       = azurerm_linux_virtual_machine.linux-vm[*].name
}

output "vm_hostnames" {
  description = "Computer names (hostnames) of the created virtual machines"
  value       = azurerm_linux_virtual_machine.linux-vm[*].computer_name
}

output "vm_ids" {
  description = "IDs of the created virtual machines"
  value       = azurerm_linux_virtual_machine.linux-vm[*].id
}

output "vm_private_ip_addresses" {
  description = "Private IP addresses of the created virtual machines"
  value       = azurerm_linux_virtual_machine.linux-vm[*].private_ip_address
}

output "vm_public_ip_addresses" {
  description = "Public IP addresses of the created virtual machines (if any)"
  value       = azurerm_linux_virtual_machine.linux-vm[*].public_ip_address
}

output "network_interface_ids" {
  description = "IDs of the network interfaces"
  value       = azurerm_network_interface.linux-nic[*].id
}

output "network_interface_private_ips" {
  description = "Private IP addresses assigned to the network interfaces"
  value       = azurerm_network_interface.linux-nic[*].private_ip_address
}

output "vm_sizes" {
  description = "Sizes of the created virtual machines"
  value       = azurerm_linux_virtual_machine.linux-vm[*].size
}

output "os_disk_names" {
  description = "Names of the OS disks"
  value       = azurerm_linux_virtual_machine.linux-vm[*].os_disk[0].name
}

output "vm_location" {
  description = "Location where the VMs are deployed"
  value       = var.location
}

output "resource_group_name" {
  description = "Name of the resource group containing the VMs"
  value       = var.rgname
}

output "vm_tags" {
  description = "Tags applied to the virtual machines"
  value       = local.vm_tags
}

output "generation_2_features" {
  description = "Generation 2 and security features status"
  value = {
    generation_2_enabled    = var.enable_generation_2
    secure_boot_enabled     = var.enable_generation_2 && var.enable_secure_boot
    vtpm_enabled           = var.enable_generation_2 && var.enable_vtpm
    confidential_vm_enabled = var.enable_confidential_vm
    security_encryption    = var.enable_confidential_vm ? var.security_encryption_type : "None"
    is_confidential_size   = local.is_confidential_vm_size
    vm_size               = var.size
  }
}

output "monitoring_status" {
  description = "Status of monitoring and extension deployments"
  value = {
    azure_monitor_enabled     = var.enable_azure_monitor
    dependency_agent_enabled  = var.enable_dependency_agent
    guest_configuration_enabled = var.enable_guest_configuration
    boot_diagnostics_enabled  = var.enable_boot_diagnostics
    patch_management_enabled  = var.enable_patch_management
    data_collection_rule_associated = var.data_collection_rule_id != null && var.enable_azure_monitor
  }
}

output "security_features" {
  description = "Security features configuration"
  value = {
    encryption_at_host_enabled = var.enable_encryption_at_host
    disable_password_authentication = var.disable_password_authentication
    ssh_authentication_enabled = true
    confidential_vm_enabled = var.enable_confidential_vm
    os_disk_storage_type = var.os_disk_storage_account_type
  }
}

output "vm_image_info" {
  description = "Information about the VM image used"
  value = {
    publisher = var.vm_image.publisher
    offer     = var.vm_image.offer
    sku       = var.vm_image.sku
    version   = var.vm_image.version
    os_type   = "Linux"
    distribution = "Ubuntu"
    version_number = "24.04"
  }
}

output "syslog_server_info" {
  description = "Syslog server configuration details"
  value = var.enable_syslog_server ? {
    enabled             = var.enable_syslog_server
    port               = var.syslog_port
    protocol           = var.syslog_protocol
    tls_enabled        = var.enable_syslog_tls
    allowed_networks   = var.syslog_allowed_networks
    log_retention_days = var.syslog_log_retention_days
    max_log_size       = var.syslog_max_log_size
    server_endpoints   = [
      for ip in azurerm_linux_virtual_machine.linux-vm[*].private_ip_address :
      "syslog://${ip}:${var.syslog_port}"
    ]
  } : {
    enabled = false
  }
}
