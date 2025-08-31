resource "azurerm_network_interface" "linux-nic" {
  count               = var.server_count
  name                = "${local.nic_base_name}-${format("%02d", count.index + 1)}"
  location            = var.location
  resource_group_name = var.rgname
  tags                = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnetid
    private_ip_address_allocation = "Dynamic"
  }
  
  lifecycle {
    ignore_changes = [ip_configuration[0]]
  }
}

# Validation for Confidential VM configuration
resource "null_resource" "confidential_vm_validation" {
  count = var.enable_confidential_vm && !local.is_confidential_vm_size ? 1 : 0
  
  provisioner "local-exec" {
    command = "echo 'ERROR: Confidential VMs require DCasv5-series or ECasv5-series VM sizes. Current size: ${var.size}' && exit 1"
  }
}

resource "azurerm_linux_virtual_machine" "linux-vm" {
  count               = var.server_count
  name                = "${local.vm_base_name}-${format("%02d", count.index + 1)}"
  computer_name       = "${local.hostname_base}${format("%02d", count.index + 1)}"
  depends_on          = [azurerm_network_interface.linux-nic]
  resource_group_name = var.rgname
  location            = var.location
  size                = var.size
  admin_username      = var.admin_username
  disable_password_authentication = var.disable_password_authentication
  custom_data         = local.default_custom_data
  patch_mode          = var.enable_patch_management ? "AutomaticByPlatform" : "ImageDefault"
  patch_assessment_mode = var.enable_patch_management ? "AutomaticByPlatform" : "ImageDefault"
  encryption_at_host_enabled = var.enable_encryption_at_host
  provision_vm_agent  = var.provision_vm_agent
  tags                = local.vm_tags
  
  # Generation 2 VM specific configurations
  secure_boot_enabled = var.enable_generation_2 && var.enable_secure_boot
  vtpm_enabled       = var.enable_generation_2 && var.enable_vtpm
  
  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = null
    }
  }
  
  lifecycle {
    ignore_changes = [tags.CreatedDate, tags.ExpiryDate, tags, identity, custom_data]
  }
  
  network_interface_ids = [
    azurerm_network_interface.linux-nic[count.index].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    name                 = "${local.disk_base_name}-${format("%02d", count.index + 1)}"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
    
    # Confidential VM disk encryption configuration
    security_encryption_type = var.enable_confidential_vm ? var.security_encryption_type : null
    disk_encryption_set_id   = var.enable_confidential_vm && var.security_encryption_type == "DiskWithVMGuestState" ? var.confidential_vm_disk_encryption_set_id : null
  }

  source_image_reference {
    offer     = lookup(var.vm_image, "offer", null)
    publisher = lookup(var.vm_image, "publisher", null)
    sku       = lookup(var.vm_image, "sku", null)
    version   = lookup(var.vm_image, "version", null)
  }
}

# Azure Monitor Agent Extension
resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  count                      = var.enable_azure_monitor ? var.server_count : 0
  depends_on                 = [azurerm_linux_virtual_machine.linux-vm]
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.linux-vm[count.index].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.21"
  auto_upgrade_minor_version = var.enable_automatic_upgrades
  automatic_upgrade_enabled  = var.enable_automatic_upgrades

  lifecycle {
    ignore_changes = [tags]
  }
}

# Dependency Agent Extension
resource "azurerm_virtual_machine_extension" "dependency_agent" {
  count                      = var.enable_dependency_agent ? var.server_count : 0
  depends_on                 = [azurerm_virtual_machine_extension.azure_monitor_agent]
  name                       = "DependencyAgentLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.linux-vm[count.index].id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = "9.10"
  auto_upgrade_minor_version = var.enable_automatic_upgrades
  automatic_upgrade_enabled  = var.enable_automatic_upgrades

  lifecycle {
    ignore_changes = [tags]
  }
}

# Guest Configuration Extension
resource "azurerm_virtual_machine_extension" "guest_configuration" {
  count                      = var.enable_guest_configuration ? var.server_count : 0
  depends_on                 = [azurerm_virtual_machine_extension.dependency_agent]
  name                       = "AzurePolicyforLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.linux-vm[count.index].id
  publisher                  = "Microsoft.GuestConfiguration"
  type                       = "ConfigurationforLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = var.enable_automatic_upgrades
  automatic_upgrade_enabled  = var.enable_automatic_upgrades

  lifecycle {
    ignore_changes = [tags]
  }
}

# Azure Monitor Data Collection Rule Association
resource "azurerm_monitor_data_collection_rule_association" "vm_dcr_association" {
  count                   = var.data_collection_rule_id != null && var.enable_azure_monitor ? var.server_count : 0
  depends_on              = [azurerm_virtual_machine_extension.azure_monitor_agent]
  name                    = "dcr-association-${azurerm_linux_virtual_machine.linux-vm[count.index].name}"
  target_resource_id      = azurerm_linux_virtual_machine.linux-vm[count.index].id
  data_collection_rule_id = var.data_collection_rule_id
}
