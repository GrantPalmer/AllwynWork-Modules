# Enhanced variables for subscription creation and access management
variable "billing_account_name" {
  description = "The billing account name for subscription creation"
  type        = string
  default     = ""
}

variable "billing_profile_name" {
  description = "The billing profile name for subscription creation"
  type        = string
  default     = ""
}

variable "invoice_section_name" {
  description = "The invoice section name for subscription creation"
  type        = string
  default     = ""
}

variable "subscription_name" {
  description = "Name for the new subscription"
  type        = string
  default     = "AUK-Sandbox-Subscription"
}

variable "subscription_workload" {
  description = "Workload type for the subscription"
  type        = string
  default     = "DevTest"
  validation {
    condition     = contains(["DevTest", "Production"], var.subscription_workload)
    error_message = "Workload must be either 'DevTest' or 'Production'."
  }
}

variable "create_new_subscription" {
  description = "Whether to create a new subscription or use existing"
  type        = bool
  default     = false
}

variable "existing_subscription_id" {
  description = "Existing subscription ID to use if not creating new one"
  type        = string
  default     = ""
}

# Access package variables
variable "create_access_package" {
  description = "Whether to create an access package for subscription access"
  type        = bool
  default     = true
}

variable "access_package_name" {
  description = "Name for the access package"
  type        = string
  default     = "Sandbox Subscription Access"
}

variable "access_package_description" {
  description = "Description for the access package"
  type        = string
  default     = "Provides contributor access to sandbox subscription for development and testing"
}

variable "catalog_id" {
  description = "Azure AD catalog ID for access packages"
  type        = string
  default     = ""
}

variable "requestor_group_object_id" {
  description = "Object ID of the group that can request access"
  type        = string
  default     = ""
}

variable "approver_group_object_id" {
  description = "Object ID of the group that approves access requests"
  type        = string
  default     = ""
}
