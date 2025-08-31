variable "access_package_name" {
  description = "Name of the access package"
  type        = string
}

variable "access_package_description" {
  description = "Description of the access package"
  type        = string
}

variable "catalog_id" {
  description = "Azure AD catalog ID"
  type        = string
}

variable "subscription_id" {
  description = "Target subscription ID for access"
  type        = string
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

variable "access_duration_days" {
  description = "Duration of access in days"
  type        = number
  default     = 30
}

variable "role_assignments" {
  description = "List of role assignments to include in the access package"
  type = list(object({
    role_definition_name = string
    scope_type          = string # "subscription" or "resource_group"
    scope_name          = optional(string, "") # resource group name if scope_type is "resource_group"
  }))
  default = [
    {
      role_definition_name = "Contributor"
      scope_type          = "subscription"
    }
  ]
}
