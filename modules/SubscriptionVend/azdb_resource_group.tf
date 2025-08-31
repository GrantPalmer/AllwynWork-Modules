locals {
  # Map subscription workload to environment code
  environment_map = {
    "DevTest"    = "dev"
    "Production" = "prd"
  }
  environment_code = local.environment_map[var.subscription_workload]
}

module "sandbox_rg_01" {
  source = "./modules/module_resource_group"
  subscription_name = var.subscription_name
  app_short_code = var.app_short_code
  environment = local.environment_code
  increment = var.resource_increment
  resource_group_location = "UK South"
  resource_group_tags = merge(
    { 
      Workload = "Sandbox Environment"
      AppShortCode = var.app_short_code
      Environment = local.environment_code
    }, 
    var.default_tags
  )
}
