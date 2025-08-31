variable "role_assignment_scope" {
  description = "Resource ID of assingment scope"
  type        = string
}

variable "role_assignment_name" {
  description = "Role Assignment role name eg Reader"
  type        = string
}

variable "role_assignment_upn" {
  description = "ObjectID of identity to assign role"
  type        = string
}