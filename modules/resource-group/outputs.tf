output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "The name of the created resource group"
}

output "resource_group_id" {
  value       = azurerm_resource_group.rg.id
  description = "The ID of the created resource group"
}

output "resource_group_location" {
  value       = azurerm_resource_group.rg.location
  description = "The location/region of the resource group"
}

output "tags" {
  value       = azurerm_resource_group.rg.tags
  description = "The tags applied to the resource group"
}

# User access outputs
output "contributor_users_assigned" {
  value       = var.contributor_users
  description = "List of users assigned Contributor role"
}

output "reader_users_assigned" {
  value       = var.reader_users
  description = "List of users assigned Reader role"
}

output "owner_users_assigned" {
  value       = var.owner_users
  description = "List of users assigned Owner role"
}

output "role_assignments" {
  value = {
    contributors = [for user in var.contributor_users : {
      user = user
      role = "Contributor"
      id   = azurerm_role_assignment.contributor_users[user].id
    }]
    readers = [for user in var.reader_users : {
      user = user
      role = "Reader"
      id   = azurerm_role_assignment.reader_users[user].id
    }]
    owners = [for user in var.owner_users : {
      user = user
      role = "Owner"
      id   = azurerm_role_assignment.owner_users[user].id
    }]
  }
  description = "Details of all role assignments created"
}