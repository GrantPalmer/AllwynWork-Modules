resource "azurerm_network_interface" "adds-nic" {
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

resource "random_password" "password" {
  count            = var.server_count
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Validation for Confidential VM configuration
resource "null_resource" "confidential_vm_validation" {
  count = var.enable_confidential_vm && !local.is_confidential_vm_size ? 1 : 0
  
  provisioner "local-exec" {
    command = "echo 'ERROR: Confidential VMs require DCasv5-series or ECasv5-series VM sizes. Current size: ${var.size}' && exit 1"
  }
}

resource "azurerm_windows_virtual_machine" "adds-vm" {
  count               = var.server_count
  name                = "${local.vm_base_name}-${format("%02d", count.index + 1)}"
  computer_name       = "${local.hostname_base}${format("%02d", count.index + 1)}"
  depends_on          = [azurerm_network_interface.adds-nic]
  resource_group_name = var.rgname
  location            = var.location
  size                = var.size
  admin_username      = var.admin_username
  admin_password      = resource.random_password.password[count.index].result
  timezone            = "GMT Standard Time"
  patch_mode          = var.enable_patch_management ? "AutomaticByPlatform" : "Manual"
  patch_assessment_mode = var.enable_patch_management ? "AutomaticByPlatform" : "ImageDefault"
  encryption_at_host_enabled = var.enable_encryption_at_host
  provision_vm_agent  = true
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
    ignore_changes = [tags.CreatedDate, tags.ExpiryDate, tags, identity]
  }
  
  network_interface_ids = [
    azurerm_network_interface.adds-nic[count.index].id,
  ]

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

resource "azurerm_virtual_machine_extension" "join-domain" {
  count                      = var.server_count
  name                       = "join-domain"
  virtual_machine_id         = azurerm_windows_virtual_machine.adds-vm[count.index].id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true
  
  settings = <<SETTINGS
    {
        "Name": "${var.active_directory_domain}",
        "OUPath": "${var.ou_path != null ? var.ou_path : ""}",
        "User": "${var.active_directory_username}@${var.active_directory_domain}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<SETTINGS
    {
        "Password": "${var.active_directory_password}"
    }
SETTINGS
}

# Guest Configuration Extension
resource "azurerm_virtual_machine_extension" "guest_configuration" {
  count                      = var.enable_guest_configuration ? var.server_count : 0
  depends_on                 = [azurerm_virtual_machine_extension.join-domain]
  name                       = "AzurePolicyforWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.adds-vm[count.index].id
  publisher                  = "Microsoft.GuestConfiguration"
  type                       = "ConfigurationforWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  
  lifecycle {
    ignore_changes = [automatic_upgrade_enabled]
  }
}

# Dependency Agent Extension
resource "azurerm_virtual_machine_extension" "dependency_agent" {
  count                      = var.enable_dependency_agent ? var.server_count : 0
  depends_on                 = [azurerm_virtual_machine_extension.join-domain]
  name                       = "DependencyAgentWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.adds-vm[count.index].id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.10"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
}

# Azure Monitor Agent Extension
resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  count                      = var.enable_azure_monitor ? var.server_count : 0
  depends_on                 = [azurerm_virtual_machine_extension.join-domain]
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.adds-vm[count.index].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.5"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
}

# Data Collection Rule Association
resource "azurerm_monitor_data_collection_rule_association" "dcra" {
  count                   = var.enable_azure_monitor && var.data_collection_rule_id != null ? var.server_count : 0
  name                    = "${local.vm_base_name}-${format("%02d", count.index + 1)}-dcra"
  target_resource_id      = azurerm_windows_virtual_machine.adds-vm[count.index].id
  data_collection_rule_id = var.data_collection_rule_id
}

# UK Locale Setting Extension
resource "azurerm_virtual_machine_extension" "set_locale" {
  count                = var.enable_locale_setting ? var.server_count : 0
  depends_on           = [azurerm_virtual_machine_extension.join-domain]
  name                 = "SetLocale"
  virtual_machine_id   = azurerm_windows_virtual_machine.adds-vm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe Set-WinSystemLocale -SystemLocale 'en-GB'; Set-Culture -CultureInfo 'en-GB'; Set-WinHomeLocation -GeoId 242; Set-WinUserLanguageList 'en-GB' -Force; Restart-Computer -Force"
    }
SETTINGS
}