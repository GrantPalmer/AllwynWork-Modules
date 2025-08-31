# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : null
  tags                = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# Network Security Groups - one per subnet
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.subnets
  name                = local.nsg_names[each.key]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# NSG Security Rules
resource "azurerm_network_security_rule" "nsg_rules" {
  for_each = {
    for rule_key in flatten([
      for subnet_key, rules in local.all_nsg_rules : [
        for rule_name, rule_config in rules : {
          key                        = "${subnet_key}-${rule_name}"
          subnet_key                 = subnet_key
          rule_name                  = rule_name
          priority                   = rule_config.priority
          direction                  = rule_config.direction
          access                     = rule_config.access
          protocol                   = rule_config.protocol
          source_port_range          = rule_config.source_port_range
          destination_port_range     = rule_config.destination_port_range
          destination_port_ranges    = rule_config.destination_port_ranges
          source_address_prefix      = rule_config.source_address_prefix
          source_address_prefixes    = rule_config.source_address_prefixes
          destination_address_prefix = rule_config.destination_address_prefix
          destination_address_prefixes = rule_config.destination_address_prefixes
          description               = rule_config.description
        }
      ]
    ]) : rule_key.key => rule_key
  }

  name                         = each.value.rule_name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range            = each.value.source_port_range
  destination_port_range       = each.value.destination_port_range
  destination_port_ranges      = each.value.destination_port_ranges
  source_address_prefix        = each.value.source_address_prefix
  source_address_prefixes      = each.value.source_address_prefixes
  destination_address_prefix   = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes
  description                  = each.value.description
  resource_group_name          = var.resource_group_name
  network_security_group_name  = azurerm_network_security_group.nsg[each.value.subnet_key].name
}

# Route Tables - one per subnet
resource "azurerm_route_table" "rt" {
  for_each            = var.subnets
  name                = local.rt_names[each.key]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# Routes
resource "azurerm_route" "routes" {
  for_each = {
    for route_key in flatten([
      for subnet_key, routes in local.all_routes : [
        for route_name, route_config in routes : {
          key                    = "${subnet_key}-${route_name}"
          subnet_key             = subnet_key
          route_name             = route_name
          address_prefix         = route_config.address_prefix
          next_hop_type          = route_config.next_hop_type
          next_hop_in_ip_address = route_config.next_hop_in_ip_address
        }
      ]
    ]) : route_key.key => route_key
  }

  name                   = each.value.route_name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.rt[each.value.subnet_key].name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}

# Subnets
resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = local.subnet_names[each.key]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

# Associate NSGs with Subnets
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each                  = var.subnets
  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

# Associate Route Tables with Subnets
resource "azurerm_subnet_route_table_association" "rt_association" {
  for_each       = var.subnets
  subnet_id      = azurerm_subnet.subnets[each.key].id
  route_table_id = azurerm_route_table.rt[each.key].id
}

