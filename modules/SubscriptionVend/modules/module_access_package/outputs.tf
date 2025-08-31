output "access_package_id" {
  description = "ID of the created access package"
  value       = azuread_access_package.subscription_access.id
}

output "access_package_name" {
  description = "Name of the created access package"
  value       = azuread_access_package.subscription_access.display_name
}

output "assignment_policy_id" {
  description = "ID of the access package assignment policy"
  value       = azuread_access_package_assignment_policy.policy.id
}
