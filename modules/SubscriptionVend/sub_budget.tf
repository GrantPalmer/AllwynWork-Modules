module "sub_budget_01" {
  source = "./modules/module_budget"
  subscription_name = var.subscription_name
  app_short_code = var.app_short_code
  environment = local.environment_code
  budget_amount = var.budget_amount
  increment = var.resource_increment
  budget_contacts = var.budget_contacts
}
