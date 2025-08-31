output "id" {
  description = "ID of the created Key Vault"
  value       = azurerm_key_vault.core.id
}

output "vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.core.vault_uri
}

output "name" {
  description = "Name of the created Key Vault"
  value       = azurerm_key_vault.core.name
}

output "resource_group_name" {
  description = "Resource group name where the Key Vault is created"
  value       = azurerm_key_vault.core.resource_group_name
}

output "location" {
  description = "Location where the Key Vault is created"
  value       = azurerm_key_vault.core.location
}

output "applied_tags" {
  description = "The final set of tags applied to the Key Vault"
  value       = local.tags
}

