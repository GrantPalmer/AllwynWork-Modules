output "subscription_id" {
  description = "Target subscription ID (created or existing)"
  value       = local.target_subscription_id
}

output "new_subscription_created" {
  description = "Whether a new subscription was created"
  value       = var.create_new_subscription
}

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = module.sandbox_rg_01.resource_group_name
}

output "resource_group_id" {
  description = "ID of the created resource group"
  value       = module.sandbox_rg_01.resource_group_id
}

output "vnet_id" {
  description = "ID of the created virtual network"
  value       = module.sandbox_vnet_01.vnet_id
}

output "vnet_name" {
  description = "Name of the created virtual network"
  value       = module.sandbox_vnet_01.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = module.sandbox_vnet_01.subnet_ids
}

output "budget_name" {
  description = "Name of the subscription budget"
  value       = module.sub_budget_01.budget_name
}

output "access_package_id" {
  description = "ID of the created access package"
  value       = var.create_access_package ? module.subscription_access_package[0].access_package_id : null
}

output "access_package_name" {
  description = "Name of the created access package"
  value       = var.create_access_package ? module.subscription_access_package[0].access_package_name : null
}

# Remove the duplicate data source since it's now in subscription_creation.tf
# data "azurerm_subscription" "current" {}
