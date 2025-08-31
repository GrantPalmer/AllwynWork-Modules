output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Virtual Network Name"
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value = {
    for subnet_key, subnet in azurerm_subnet.subnets :
    subnet_key => subnet.id
  }
}

output "subnet_names" {
  description = "Map of subnet keys to names"
  value = {
    for subnet_key, subnet in azurerm_subnet.subnets :
    subnet_key => subnet.name
  }
}
