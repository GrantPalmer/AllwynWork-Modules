output "admin_passwords" {
  description = "The auto-generated admin passwords for the VMs"
  value       = resource.random_password.password[*].result
  sensitive   = true
}

output "admin_username" {
  description = "The admin username for the VMs"
  value       = var.admin_username
}

output "vm_names" {
  description = "Names of the created virtual machines"
  value       = azurerm_windows_virtual_machine.adds-vm[*].name
}

output "vm_hostnames" {
  description = "Computer names (hostnames) of the created virtual machines"
  value       = azurerm_windows_virtual_machine.adds-vm[*].computer_name
}

output "vm_ids" {
  description = "IDs of the created virtual machines"
  value       = azurerm_windows_virtual_machine.adds-vm[*].id
}

output "nic_names" {
  description = "Names of the created network interfaces"
  value       = azurerm_network_interface.adds-nic[*].name
}

output "nic_ids" {
  description = "IDs of the created network interfaces"
  value       = azurerm_network_interface.adds-nic[*].id
}

output "private_ip_addresses" {
  description = "Private IP addresses of the VMs"
  value       = azurerm_network_interface.adds-nic[*].ip_configuration[0].private_ip_address
}

output "applied_tags" {
  description = "The final set of tags applied to all resources"
  value       = local.tags
}

output "vm_tags" {
  description = "The final set of tags applied to VMs (includes VM-specific AutoSchedule tag)"
  value       = local.vm_tags
}

output "extensions_installed" {
  description = "List of extensions installed on the VMs"
  value = {
    domain_join         = true
    guest_configuration = var.enable_guest_configuration
    dependency_agent    = var.enable_dependency_agent
    azure_monitor       = var.enable_azure_monitor
    locale_setting      = var.enable_locale_setting
  }
}

output "generation_2_features" {
  description = "Generation 2 VM features enabled"
  value = {
    generation_2_enabled    = var.enable_generation_2
    secure_boot_enabled     = var.enable_generation_2 && var.enable_secure_boot
    vtpm_enabled           = var.enable_generation_2 && var.enable_vtpm
    confidential_vm_enabled = var.enable_confidential_vm
    security_encryption    = var.enable_confidential_vm ? var.security_encryption_type : "Not applicable"
    vm_image_sku          = lookup(var.vm_image, "sku", null)
    vm_size               = var.size
    is_confidential_size  = local.is_confidential_vm_size
  }
}

output "dcr_associations" {
  description = "Data Collection Rule associations created"
  value       = var.enable_azure_monitor && var.data_collection_rule_id != null ? azurerm_monitor_data_collection_rule_association.dcra[*].name : []
}