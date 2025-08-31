terraform {
  backend "azurerm" {
    use_azuread_auth = true
  }
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0.0"
    }
  }
}

# Default provider for management operations (if creating subscriptions)
provider "azurerm" {
  features {}
  storage_use_azuread = true
  # Remove hard-coded subscription_id to allow for subscription creation
}

provider "azuread" {
}