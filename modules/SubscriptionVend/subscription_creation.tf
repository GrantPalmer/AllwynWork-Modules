# Data source for billing account information
data "azurerm_billing_enrollment_account_scope" "billing_scope" {
  count                = var.create_new_subscription && var.billing_account_name != "" ? 1 : 0
  billing_account_name = var.billing_account_name
  enrollment_account_name = var.billing_account_name
}

# Create new subscription (if enabled)
resource "azurerm_subscription" "new_subscription" {
  count            = var.create_new_subscription ? 1 : 0
  subscription_name = var.subscription_name
  billing_scope_id  = var.billing_account_name != "" ? data.azurerm_billing_enrollment_account_scope.billing_scope[0].id : null
  workload          = var.subscription_workload
  
  tags = merge(
    {
      Purpose = "Sandbox"
      Environment = "Development"
      CreatedBy = "Terraform"
    },
    var.default_tags
  )
}

# Local to determine which subscription to use
locals {
  target_subscription_id = var.create_new_subscription ? azurerm_subscription.new_subscription[0].subscription_id : var.existing_subscription_id
}

# Provider configuration for the target subscription
provider "azurerm" {
  alias           = "target_subscription"
  features {}
  subscription_id = local.target_subscription_id
  storage_use_azuread = true
}

# Move existing resource group to use the target subscription provider
module "sandbox_rg_01" {
  source = "./modules/module_resource_group"
  
  providers = {
    azurerm = azurerm.target_subscription
  }
  
  resource_group_name     = "sandbox_rg_01"
  resource_group_location = "UK South"
  resource_group_tags = merge(
    { 
      Workload = "Sandbox Environment" 
    }, 
    var.default_tags
  )
}

# Move existing VNet to use the target subscription provider
module "sandbox_vnet_01" {
  source = "./modules/module_vnet"
  
  providers = {
    azurerm = azurerm.target_subscription
  }
  
  vnet_name                = "sandbox_vnet_01"
  vnet_location            = "UK South"
  vnet_resource_group_name = module.sandbox_rg_01.resource_group_name
  vnet_address_space       = ["10.0.0.0/16"]
  vnet_tags = merge(
    { 
      Workload = "Sandbox Environment",
      Purpose = "General Sandbox"
    }, 
    var.default_tags
  )
  
  # Default subnets for sandbox environment
  subnets = {
    default = {
      address_prefixes = ["10.0.1.0/24"]
    }
    web = {
      address_prefixes = ["10.0.2.0/24"]
    }
    data = {
      address_prefixes = ["10.0.3.0/24"]
    }
  }
}

# Move existing budget to use the target subscription provider
module "sub_budget_01" {
  source = "./modules/module_budget"
  
  providers = {
    azurerm = azurerm.target_subscription
  }
  
  budget_amount = "100"
  budget_name = "AUK-SBX-Sandbox-001_Budget_01"
  budget_contacts = [
    "grant.palmer@allwyn.co.uk"
  ]
}
