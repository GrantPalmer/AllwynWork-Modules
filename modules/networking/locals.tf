locals {
  # Construct virtual network name with flexible naming pattern
  vnet_name = var.app_shortcode != "" ? "${var.region}-${var.environment}-${var.platform_name}-${var.purpose}-${var.app_shortcode}-vnet-${var.instance}" : "${var.region}-${var.environment}-${var.platform_name}-${var.purpose}-vnet-${var.instance}"

  current_timestamp = timestamp()
  expiry            = timeadd(local.current_timestamp, "26280h")

  # Merged tags combining default tags with user-provided tags
  tags = merge({
    Environment = var.environment
    Department  = "TechOps"
    Source      = "terraform"
    CreatedDate = formatdate("DD-MM-YYYY", local.current_timestamp)
    ExpiryDate  = formatdate("DD-MM-YYYY", local.expiry)
    Project     = "CoreServices"
    CostCenter  = "TBC"
    RFC         = "TBC"
  }, var.tags)

  # Create subnet names following the same naming convention
  subnet_names = {
    for subnet_key, subnet_config in var.subnets :
    subnet_key => var.app_shortcode != "" ? "${var.region}-${var.environment}-${var.platform_name}-${var.purpose}-${var.app_shortcode}-snet-${subnet_key}-${var.instance}" : "${var.region}-${var.environment}-${var.platform_name}-${var.purpose}-snet-${subnet_key}-${var.instance}"
  }

  # Create NSG names for each subnet
  nsg_names = {
    for subnet_key, subnet_config in var.subnets :
    subnet_key => var.app_shortcode != "" ? "${var.region}-${var.environment}-${var.platform_name}-${var.purpose}-${var.app_shortcode}-nsg-${subnet_key}-${var.instance}" : "${var.region}-${var.environment}-${var.platform_name}-${var.purpose}-nsg-${subnet_key}-${var.instance}"
  }

  # Create Route Table names for each subnet
  rt_names = {
    for subnet_key, subnet_config in var.subnets :
    subnet_key => var.app_shortcode != "" ? "${var.region}-${var.environment}-${var.platform_name}-${var.purpose}-${var.app_shortcode}-rt-${subnet_key}-${var.instance}" : "${var.region}-${var.environment}-${var.platform_name}-${var.purpose}-rt-${subnet_key}-${var.instance}"
  }

  # Flatten subnet-specific and global NSG rules
  all_nsg_rules = {
    for subnet_key, subnet_config in var.subnets :
    subnet_key => merge(var.global_nsg_rules, subnet_config.nsg_rules)
  }

  # Flatten subnet-specific and global routes
  all_routes = {
    for subnet_key, subnet_config in var.subnets :
    subnet_key => merge(var.global_routes, subnet_config.routes)
  }
}
