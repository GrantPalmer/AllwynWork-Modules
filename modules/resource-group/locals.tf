locals {
  # Parse subscription name to extract components for naming
  # Example: "sub_auk_platform_security" -> ["sub", "auk", "platform", "security"]
  subscription_parts = var.subscription_name != "" ? split("_", var.subscription_name) : []
  
  # Extract the purpose/workload component (4th component - index 3)
  # For "sub_auk_platform_security" -> "security"
  # For "sub_auk_platform_eventhub" -> "eventhub"
  purpose_component = length(local.subscription_parts) >= 4 ? lower(element(local.subscription_parts, 3)) : lower(var.purpose)
  
  # Validate that we have sufficient components for new naming pattern
  use_new_pattern = var.subscription_name != "" && var.app_shortcode != ""
  
  # Construct resource group name following pattern: rg-{purpose}-{app_shortcode}-{environment}-{instance}
  # Example: rg-security-evh-prd-01
  resource_group_name = local.use_new_pattern ? "rg-${local.purpose_component}-${var.app_shortcode}-${var.environment}-${var.instance}" : (var.app_shortcode != "" ? "${var.region}-${var.environment}-${var.platform_name}-${var.purpose}-${var.app_shortcode}-rg-${var.instance}" : "${var.region}-${var.environment}-${var.platform_name}-${var.purpose}-rg-${var.instance}")

  current_timestamp = timestamp()
  expiry            = timeadd(local.current_timestamp, "26280h")

  # Merged tags combining default tags with user-provided tags
  tags = merge({
    Environment     = var.environment
    Department      = "TechOps"
    Source          = "terraform"
    CreatedDate     = formatdate("DD-MM-YYYY", local.current_timestamp)
    ExpiryDate      = formatdate("DD-MM-YYYY", local.expiry)
    Project         = "CoreServices"
    CostCenter      = "TBC"
    RFC             = "TBC"
    AppShortCode    = var.app_shortcode
    Purpose         = local.purpose_component
    NamingPattern   = local.use_new_pattern ? "standard" : "legacy"
    ContributorUsers = length(var.contributor_users) > 0 ? join(",", var.contributor_users) : "none"
    ReaderUsers     = length(var.reader_users) > 0 ? join(",", var.reader_users) : "none"
    OwnerUsers      = length(var.owner_users) > 0 ? join(",", var.owner_users) : "none"
  }, var.tags)
}