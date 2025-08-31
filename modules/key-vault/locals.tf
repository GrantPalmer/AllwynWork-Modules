locals {
  # Key Vault naming convention: KV-<PURPOSE>-<APP_CODE>-<ENVIRONMENT>-<INSTANCE>
  # Aligned with virtual-machine module naming standards (UPPERCASE with hyphens, same component order)
  kv_name = "KV-${upper(var.purpose)}-${upper(var.app_shortcode != "" ? var.app_shortcode : "AUK")}-${upper(var.environment)}-${var.instance}"
  
  # Timestamps for tags
  current_timestamp = timestamp()
  expiry = timeadd(local.current_timestamp, "${var.expiry_hours}h")
  
  # Standard tags (consistent with VM module)
  base_tags = {
    Environment = title(var.environment)
    Department  = var.department
    Source      = "terraform"
    Project     = var.project
    CostCenter  = var.cost_center
    RFC         = var.rfc
    UpdateRing  = var.update_ring
  }
  
  # Timestamp tags 
  timestamp_tags = {
    CreatedDate = formatdate("DD-MM-YYYY", local.current_timestamp)
    ExpiryDate  = formatdate("DD-MM-YYYY", local.expiry)
  }
  
  # Final tags (base + timestamp + user-provided)
  tags = merge(
    local.base_tags,
    local.timestamp_tags,
    var.tags
  )
}