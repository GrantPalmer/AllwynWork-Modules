variable "default_tags" {
  type = map(string)
  default = {
    DeployedBy = "azdo terraform"
  }
}

# Resource naming variables
variable "app_short_code" {
  description = "Application short code for resource naming (e.g., 'sbx', 'evh', 'sec')"
  type        = string
  default     = "sbx"
  validation {
    condition     = length(var.app_short_code) <= 4 && length(var.app_short_code) >= 2
    error_message = "App short code must be between 2-4 characters."
  }
}

variable "resource_increment" {
  description = "Increment number for resources"
  type        = string
  default     = "01"
  validation {
    condition     = can(regex("^[0-9]{2}$", var.resource_increment))
    error_message = "Resource increment must be a 2-digit number (e.g., '01', '02')."
  }
}

# Budget configuration
variable "budget_amount" {
  description = "Annual budget amount in GBP"
  type        = number
  default     = 100
}

variable "budget_contacts" {
  description = "List of email contacts for budget notifications"
  type        = list(string)
  default     = ["grant.palmer@allwyn.co.uk"]
}