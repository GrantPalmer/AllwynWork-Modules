# Create access package
resource "azuread_access_package" "subscription_access" {
  catalog_id   = var.catalog_id
  display_name = var.access_package_name
  description  = var.access_package_description
}

# Create assignment policy for the access package
resource "azuread_access_package_assignment_policy" "policy" {
  access_package_id = azuread_access_package.subscription_access.id
  display_name      = "${var.access_package_name} Policy"
  description       = "Assignment policy for ${var.access_package_name}"
  
  # Approval settings - simplified configuration
  approval_settings {
    approval_required = var.approver_group_object_id != "" ? true : false
    
    dynamic "approval_stage" {
      for_each = var.approver_group_object_id != "" ? [1] : []
      content {
        approval_timeout_in_days = 14
        
        primary_approver {
          object_id    = var.approver_group_object_id
          subject_type = "groupMembers"
        }
      }
    }
  }
  
  # Assignment review settings
  assignment_review_settings {
    enabled                        = true
    review_frequency              = "quarterly"
    duration_in_days              = 14
    review_type                   = "Self"
    access_review_timeout_behavior = "removeAccess"
  }
  
  # Questions for requestor
  question {
    text {
      default_text = "Please provide business justification for requesting access to this subscription."
    }
    required = true
  }
  
  # Requestor settings
  requestor_settings {
    requests_accepted = true
    scope_type        = var.requestor_group_object_id != "" ? "specificDirectorySubjects" : "allConfiguredConnectedOrganizationSubjects"
    
    dynamic "requestor" {
      for_each = var.requestor_group_object_id != "" ? [1] : []
      content {
        object_id    = var.requestor_group_object_id
        subject_type = "groupMembers"
      }
    }
  }
}
