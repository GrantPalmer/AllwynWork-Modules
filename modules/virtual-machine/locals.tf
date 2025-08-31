locals {
    # VM name following convention: VM-<PURPOSE>-<APP_CODE>-<ENVIRONMENT>-<INSTANCE>
    vm_base_name = "VM-${upper(var.purpose)}-${upper(var.app_shortcode != "" ? var.app_shortcode : "AUK")}-${upper(var.environment)}"
    
    # NIC name following convention: NIC-<subname>-vm-<purpose>-<subname>-<environment>-<INSTANCE> (lowercase)
    nic_base_name = "NIC-${lower(var.subname != "" ? var.subname : "auk")}-vm-${lower(var.purpose)}-${lower(var.subname != "" ? var.subname : "auk")}-${lower(var.environment)}"
    
    # Disk name following convention: DSK-<REGION>-<APP_CODE>-<ENVIRONMENT>-<DISK_TYPE>-<INSTANCE>
    disk_base_name = "DSK-${upper(var.region)}-${upper(var.app_shortcode != "" ? var.app_shortcode : "AUK")}-${upper(var.environment)}-${upper(var.additional_elements)}"
    
    # Hostname following convention: az<purpose><app_code><environment><instance> (all lowercase, no separators)
    hostname_base = "az${lower(var.purpose)}${lower(var.app_shortcode != "" ? var.app_shortcode : "auk")}${lower(var.environment)}"
    
    # Confidential VM validation
    is_confidential_vm_size = can(regex("^Standard_DC[0-9]+a?s_v5$|^Standard_EC[0-9]+a?s_v5$", var.size))
    
    # Timestamps for tags (optional)
    current_timestamp = timestamp()
    expiry = timeadd(local.current_timestamp, "${var.expiry_hours}h")

    # Base organizational tags (applied to ALL resources)
    base_tags = {
      Environment = title(var.environment)
      Department  = var.department
      Source      = "terraform"
      Project     = var.project
      CostCenter  = var.cost_center
      RFC         = var.rfc
      UpdateRing  = var.update_ring
    }

    # Timestamp tags (conditional)
    timestamp_tags = var.enable_timestamp_tags ? {
      CreatedDate = formatdate("DD-MM-YYYY", local.current_timestamp)
      ExpiryDate  = formatdate("DD-MM-YYYY", local.expiry)
    } : {}

    # Standard tags for all resources (base + timestamp + user)
    tags = merge(
      local.base_tags,
      local.timestamp_tags,
      var.tags
    )

    # VM-specific additional tags
    vm_specific_tags = {
      AutoSchedule = var.stop_start_schedule
    }

    # Final VM tags (all standard tags + VM-specific tags)
    vm_tags = merge(
      local.tags,
      local.vm_specific_tags
    )
}