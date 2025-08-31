resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.vnet_location
  resource_group_name = var.vnet_resource_group_name
  tags                = var.vnet_tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = "${var.vnet_name}_${each.key}_subnet"
  resource_group_name  = var.vnet_resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes
}
