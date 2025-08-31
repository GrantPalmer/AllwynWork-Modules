data "azurerm_subscription" "current" {}

locals {
  # Parse subscription name to extract the last component
  # Example: "AUK-Sandbox-Development-001" -> "001"
  subscription_parts = split("-", var.subscription_name)
  subscription_last_part = lower(element(local.subscription_parts, length(local.subscription_parts) - 1))
  
  # Build budget name following pattern: bg-{subscription_last}-{app_short_code}-{environment}-{increment}
  # Example: bg-001-sbx-dev-01
  budget_name = "bg-${local.subscription_last_part}-${var.app_short_code}-${var.environment}-${var.increment}"
  
  # Date calculations
  bg_start_date = formatdate("YYYY-MM-01'T'00:00:00Z", timestamp())
  bg_end_date   = "2050-01-01T00:00:00Z"
}

resource "azurerm_consumption_budget_subscription" "consumption_budget" {
  name            = local.budget_name
  subscription_id = data.azurerm_subscription.current.id

  amount     = var.budget_amount
  time_grain = "Annually"

  time_period {
    start_date = local.bg_start_date
    end_date   = local.bg_end_date
  }

  notification {
    enabled   = true
    threshold = 80.0
    operator  = "EqualTo"
    
    contact_emails = var.budget_contacts

    contact_roles = [
      "Owner",
      "Reader",
    ]
  }

  notification {
    enabled   = true
    threshold = 90.0
    operator  = "EqualTo"

    contact_emails = var.budget_contacts
    
    contact_roles = [
      "Owner",
      "Reader",
    ]
  }

  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    
    contact_emails = var.budget_contacts

    contact_roles = [
      "Owner",
      "Reader",
    ]
  }
}