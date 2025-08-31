data "azuread_user" "entra_id_user" {
    user_principal_name = var.role_assignment_upn
}

resource "azurerm_role_assignment" "role_assignment" {
  scope                = var.role_assignment_scope
  role_definition_name = var.role_assignment_name
  principal_id         = data.azuread_user.entra_id_user.object_id
}