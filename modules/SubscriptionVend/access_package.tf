# Create access package for subscription access (if enabled)
module "subscription_access_package" {
  count  = var.create_access_package ? 1 : 0
  source = "./modules/module_access_package"
  
  access_package_name        = var.access_package_name
  access_package_description = var.access_package_description
  catalog_id                 = var.catalog_id
  subscription_id            = local.target_subscription_id
  requestor_group_object_id  = var.requestor_group_object_id
  approver_group_object_id   = var.approver_group_object_id
  access_duration_days       = 30
  
  role_assignments = [
    {
      role_definition_name = "Contributor"
      scope_type          = "subscription"
    }
  ]
}
