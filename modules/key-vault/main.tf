resource "azurerm_key_vault" "core" {
  name                            = local.kv_name
  location                        = var.location
  resource_group_name             = var.rgname
  enabled_for_disk_encryption     = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled        = var.purge_protection_enabled
  sku_name                        = var.sku
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  soft_delete_retention_days      = 7
  tags                            = local.tags
  
  lifecycle {
    ignore_changes = [tags.CreatedDate, tags.ExpiryDate, purge_protection_enabled]
  }

  network_acls {
    default_action             = var.default_network_acl_action
    bypass                     = "AzureServices"
    ip_rules                   = var.key_vault_allowed_ips
    virtual_network_subnet_ids = var.virtual_network_subnet_ids
  }

  dynamic "access_policy" {
    for_each = var.kv_access_policies
    content {

      tenant_id = access_policy.value.tenant_id
      object_id = access_policy.value.object_id

      key_permissions     = access_policy.value.key_permissions
      secret_permissions  = access_policy.value.secret_permissions
      storage_permissions = access_policy.value.storage_permissions

    }
  }
}
