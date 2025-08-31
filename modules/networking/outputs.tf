# Virtual Network Outputs
output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "The ID of the virtual network"
}

output "vnet_name" {
  value       = azurerm_virtual_network.vnet.name
  description = "The name of the virtual network"
}

output "vnet_address_space" {
  value       = azurerm_virtual_network.vnet.address_space
  description = "The address space of the virtual network"
}

output "vnet_location" {
  value       = azurerm_virtual_network.vnet.location
  description = "The location of the virtual network"
}

# Subnet Outputs
output "subnet_ids" {
  value = {
    for subnet_key, subnet in azurerm_subnet.subnets :
    subnet_key => subnet.id
  }
  description = "Map of subnet keys to subnet IDs"
}

output "subnet_names" {
  value = {
    for subnet_key, subnet in azurerm_subnet.subnets :
    subnet_key => subnet.name
  }
  description = "Map of subnet keys to subnet names"
}

output "subnet_address_prefixes" {
  value = {
    for subnet_key, subnet in azurerm_subnet.subnets :
    subnet_key => subnet.address_prefixes
  }
  description = "Map of subnet keys to subnet address prefixes"
}

# NSG Outputs
output "nsg_ids" {
  value = {
    for nsg_key, nsg in azurerm_network_security_group.nsg :
    nsg_key => nsg.id
  }
  description = "Map of subnet keys to NSG IDs"
}

output "nsg_names" {
  value = {
    for nsg_key, nsg in azurerm_network_security_group.nsg :
    nsg_key => nsg.name
  }
  description = "Map of subnet keys to NSG names"
}

# Route Table Outputs
output "route_table_ids" {
  value = {
    for rt_key, rt in azurerm_route_table.rt :
    rt_key => rt.id
  }
  description = "Map of subnet keys to route table IDs"
}

output "route_table_names" {
  value = {
    for rt_key, rt in azurerm_route_table.rt :
    rt_key => rt.name
  }
  description = "Map of subnet keys to route table names"
}

# Combined Outputs for easy reference
output "network_summary" {
  value = {
    vnet = {
      id            = azurerm_virtual_network.vnet.id
      name          = azurerm_virtual_network.vnet.name
      address_space = azurerm_virtual_network.vnet.address_space
    }
    subnets = {
      for subnet_key, subnet in azurerm_subnet.subnets :
      subnet_key => {
        id               = subnet.id
        name             = subnet.name
        address_prefixes = subnet.address_prefixes
        nsg_id           = azurerm_network_security_group.nsg[subnet_key].id
        route_table_id   = azurerm_route_table.rt[subnet_key].id
      }
    }
  }
  description = "Complete network configuration summary"
}

output "tags" {
  value       = azurerm_virtual_network.vnet.tags
  description = "The tags applied to the networking resources"
}

