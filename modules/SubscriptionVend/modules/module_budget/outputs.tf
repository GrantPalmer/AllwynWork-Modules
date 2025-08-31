output "budget_id" {
  description = "ID of the consumption budget"
  value       = azurerm_consumption_budget_subscription.consumption_budget.id
}

output "budget_name" {
  description = "Name of the consumption budget"
  value       = azurerm_consumption_budget_subscription.consumption_budget.name
}

output "budget_amount" {
  description = "Budget amount"
  value       = azurerm_consumption_budget_subscription.consumption_budget.amount
}
