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
  description = "Environment code (e.g., 'dev', 'tst', 'prd')"
  type        = string
  default     = "dev"
}

variable "resource_group_location" {
  description = "Location of Resource Group"
  type        = string
}

variable "resource_group_tags" {
  description = "Tagging for Resource Group"
  type        = map(string)
}

variable "increment" {
  description = "Increment number for resource group"
  type        = string
  default     = "01"
}