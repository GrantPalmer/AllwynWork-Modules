# Example usage of the Windows VM Domain Join module

module "windows_vm_domain_join" {
  source = "../../"

  # Required variables
  rgname       = "rg-uks-example-prd-01"
  location     = "UK South"
  subnetid     = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/virtualNetworks/xxx/subnets/xxx"
  server_count = 2

  # Optional: Specify subscription ID if not using default
  # subscription_id = "your-subscription-id"
  
  # Naming convention variables (optional - these are defaults)
  # region                = "uks"        # Default
  # environment          = "prd"        # Default
  purpose              = "web"
  app_shortcode        = "app"
  subname             = "frontend"
  additional_elements  = "os"

  # VM configuration
  size = "Standard_D2s_v3"

  # Domain join configuration
  active_directory_domain   = "example.com"
  active_directory_username = var.domain_admin_username
  active_directory_password = var.domain_admin_password
  ou_path                  = "OU=Servers,DC=example,DC=com"

  # Enhanced tagging configuration
  department            = "Engineering"
  project              = "WebApplication"
  cost_center          = "CC-12345"
  rfc                 = "RFC-2024-001"
  stop_start_schedule  = "Weekdays=07:00-19:00 / Weekends=0"
  update_ring         = "Standard"
  enable_timestamp_tags = true
  expiry_hours        = 17520  # 2 years

  # Custom tags (these will override any conflicting base tags)
  tags = {
    Owner       = "john.doe@example.com"
    Application = "CustomerPortal"
    Criticality = "High"
    Backup      = "Daily"
  }
}

# Variables for sensitive data
variable "domain_admin_username" {
  description = "Domain administrator username"
  type        = string
  sensitive   = true
}

variable "domain_admin_password" {
  description = "Domain administrator password"
  type        = string
  sensitive   = true
}

# Outputs
output "vm_names" {
  description = "Names of the created virtual machines"
  value       = module.windows_vm_domain_join.vm_names
}

output "vm_hostnames" {
  description = "Computer names (hostnames) of the created virtual machines"
  value       = module.windows_vm_domain_join.vm_hostnames
}

output "nic_names" {
  description = "Names of the created network interfaces"
  value       = module.windows_vm_domain_join.nic_names
}
