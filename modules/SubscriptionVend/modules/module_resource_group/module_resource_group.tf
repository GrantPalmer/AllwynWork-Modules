data "azurerm_subscription" "current" {}

# Local values for parsing subscription name and building resource group name
locals {
  # Parse subscription name to extract the last component
  # Example: "AUK-Sandbox-Development-001" -> "001"
  subscription_parts = split("-", var.subscription_name)
  subscription_last_part = lower(element(local.subscription_parts, length(local.subscription_parts) - 1))
  
  # Build resource group name following pattern: rg-{subscription_last}-{app_short_code}-{environment}-{increment}
  # Example: rg-001-sbx-dev-01
  resource_group_name = "rg-${local.subscription_last_part}-${var.app_short_code}-${var.environment}-${var.increment}"
}

resource "azurerm_resource_group" "resource_group" {
  location = var.resource_group_location
  name     = local.resource_group_name
  tags     = var.resource_group_tags
}