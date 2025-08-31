output "resource_group_name" {
  description = "Name of the Resource Group"
  value       = azurerm_resource_group.resource_group.name
}

output "resource_group_id" {
  description = "ID of the Resource Group"
  value       = azurerm_resource_group.resource_group.id
}

output "resource_group_location" {
  description = "Location of the Resource Group"
  value       = azurerm_resource_group.resource_group.location
}
