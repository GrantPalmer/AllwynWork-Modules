resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
  
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Data sources to get user object IDs
data "azuread_user" "contributor_users" {
  for_each            = toset(var.contributor_users)
  user_principal_name = each.value
}

data "azuread_user" "reader_users" {
  for_each            = toset(var.reader_users)
  user_principal_name = each.value
}

data "azuread_user" "owner_users" {
  for_each            = toset(var.owner_users)
  user_principal_name = each.value
}

# Role assignments for Contributor users
resource "azurerm_role_assignment" "contributor_users" {
  for_each             = toset(var.contributor_users)
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_user.contributor_users[each.value].object_id
}

# Role assignments for Reader users
resource "azurerm_role_assignment" "reader_users" {
  for_each             = toset(var.reader_users)
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_user.reader_users[each.value].object_id
}

# Role assignments for Owner users
resource "azurerm_role_assignment" "owner_users" {
  for_each             = toset(var.owner_users)
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Owner"
  principal_id         = data.azuread_user.owner_users[each.value].object_id
}