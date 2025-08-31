variable "subscription_name" {
  description = "Full subscription name to parse for naming components"
  type        = string
}

variable "app_short_code" {
  description = "Application short code (e.g., 'sbx', 'evh', 'sec')"
  type        = string
  default     = "sbx"
}

variable "environment" {
  description = "Environment code (e.g., 'dev', 'prd')"
  type        = string
  default     = "dev"
}

variable "budget_amount" {
  description = "The budget amount in £"
  type        = number
  default     = 100
}

variable "budget_contacts" {
  description = "List of eMail contacts for budget notifications"
  type        = list(string)
  default     = ["grant.palmer@allwyn.co.uk"]
}

variable "increment" {
  description = "Increment number for budget"
  type        = string
  default     = "01"
}