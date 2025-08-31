# Azure Networking Terraform Module

This module creates a comprehensive Azure networking infrastructure including Virtual Network, Subnets, Network Security Groups with configurable rules, and Route Tables with configurable routes. All resources follow standardized naming conventions and include automated NSG and Route Table associations.

## Features

- **Virtual Network**: Single VNet with configurable address space and DNS servers
- **Subnets**: Multiple subnets with flexible configuration
- **Network Security Groups**: Automatic NSG creation per subnet with configurable rules
- **Route Tables**: Automatic Route Table creation per subnet with configurable routes
- **Global and Subnet-specific Rules**: Support for both global rules (applied to all subnets) and subnet-specific rules
- **Automatic Associations**: Automatic NSG and Route Table associations with subnets
- **Service Endpoints**: Configurable service endpoints per subnet
- **Subnet Delegation**: Support for subnet delegation to Azure services
- **Standardized Naming**: Follows established naming conventions with optional app_shortcode

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.116.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.116.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_subnet.subnets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.nsg_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_route_table.rt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_route.routes](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_subnet_network_security_group_association.nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.rt_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space that is used by the virtual network | `list(string)` | `["10.0.0.0/16"]` | no |
| <a name="input_app_shortcode"></a> [app\_shortcode](#input\_app\_shortcode) | Application short code (e.g., LSH, AUK) | `string` | `""` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of DNS servers for the VNet. If not specified, Azure-provided DNS will be used | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The deployment environment (e.g., dev, test, prod) | `string` | n/a | yes |
| <a name="input_global_nsg_rules"></a> [global\_nsg\_rules](#input\_global\_nsg\_rules) | Global NSG rules to be applied to all subnets | `map(object)` | `{}` | no |
| <a name="input_global_routes"></a> [global\_routes](#input\_global\_routes) | Global routes to be applied to all subnets | `map(object)` | `{}` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance number or unique identifier | `string` | `"01"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_platform_name"></a> [platform\_name](#input\_platform\_name) | The specific work package or platform name (e.g., lss, mds) | `string` | n/a | yes |
| <a name="input_purpose"></a> [purpose](#input\_purpose) | The purpose or function of the resource (e.g., web, db, api) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Short region code where the resource resides (e.g., uks, ukw, euw, neu, use, usw) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where resources will be created | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of subnet configurations with optional NSG rules and routes | `map(object)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_summary"></a> [network\_summary](#output\_network\_summary) | Complete network configuration summary |
| <a name="output_nsg_ids"></a> [nsg\_ids](#output\_nsg\_ids) | Map of subnet keys to NSG IDs |
| <a name="output_nsg_names"></a> [nsg\_names](#output\_nsg\_names) | Map of subnet keys to NSG names |
| <a name="output_route_table_ids"></a> [route\_table\_ids](#output\_route\_table\_ids) | Map of subnet keys to route table IDs |
| <a name="output_route_table_names"></a> [route\_table\_names](#output\_route\_table\_names) | Map of subnet keys to route table names |
| <a name="output_subnet_address_prefixes"></a> [subnet\_address\_prefixes](#output\_subnet\_address\_prefixes) | Map of subnet keys to subnet address prefixes |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Map of subnet keys to subnet IDs |
| <a name="output_subnet_names"></a> [subnet\_names](#output\_subnet\_names) | Map of subnet keys to subnet names |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags applied to the networking resources |
| <a name="output_vnet_address_space"></a> [vnet\_address\_space](#output\_vnet\_address\_space) | The address space of the virtual network |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | The ID of the virtual network |
| <a name="output_vnet_location"></a> [vnet\_location](#output\_vnet\_location) | The location of the virtual network |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | The name of the virtual network |

## Usage Examples

### Basic Network with Simple Subnets

```hcl
module "networking" {
  source = "git::https://github.com/Allwyn-UK/plat-tf-az-modules.git//modules/networking?ref=main"

  region              = "uks"
  environment         = "dev"
  platform_name       = "lss"
  purpose            = "web"
  location           = "UK South"
  resource_group_name = "rg-uks-dev-lss-web-01"
  address_space      = ["10.1.0.0/16"]

  subnets = {
    web = {
      address_prefixes = ["10.1.1.0/24"]
    }
    db = {
      address_prefixes = ["10.1.2.0/24"]
    }
  }
}
```

### Advanced Network with NSG Rules and Routes

```hcl
module "networking" {
  source = "git::https://github.com/Allwyn-UK/plat-tf-az-modules.git//modules/networking?ref=main"

  region              = "uks"
  environment         = "prod"
  platform_name       = "lss"
  purpose            = "app"
  app_shortcode      = "LSH"
  instance           = "02"
  location           = "UK South"
  resource_group_name = "rg-uks-prod-lss-app-LSH-02"
  address_space      = ["10.2.0.0/16"]
  dns_servers        = ["10.2.0.10", "10.2.0.11"]

  # Global NSG rules applied to all subnets
  global_nsg_rules = {
    "DenyAll" = {
      priority                 = 4000
      direction               = "Inbound"
      access                  = "Deny"
      protocol                = "*"
      source_address_prefix   = "*"
      destination_address_prefix = "*"
      description            = "Deny all inbound traffic as default"
    }
  }

  # Global routes applied to all subnets
  global_routes = {
    "DefaultRoute" = {
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "VirtualAppliance"
      next_hop_in_ip_address = "10.2.0.100"
    }
  }

  subnets = {
    web = {
      address_prefixes  = ["10.2.1.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      
      # Subnet-specific NSG rules
      nsg_rules = {
        "AllowHTTP" = {
          priority               = 100
          direction             = "Inbound"
          access                = "Allow"
          protocol              = "Tcp"
          destination_port_range = "80"
          source_address_prefix = "Internet"
          destination_address_prefix = "*"
          description          = "Allow HTTP from Internet"
        }
        "AllowHTTPS" = {
          priority               = 110
          direction             = "Inbound"
          access                = "Allow"
          protocol              = "Tcp"
          destination_port_range = "443"
          source_address_prefix = "Internet"
          destination_address_prefix = "*"
          description          = "Allow HTTPS from Internet"
        }
      }
      
      # Subnet-specific routes
      routes = {
        "WebSpecificRoute" = {
          address_prefix = "192.168.1.0/24"
          next_hop_type  = "VirtualNetworkGateway"
        }
      }
    }
    
    db = {
      address_prefixes = ["10.2.2.0/24"]
      
      nsg_rules = {
        "AllowSQL" = {
          priority               = 100
          direction             = "Inbound"
          access                = "Allow"
          protocol              = "Tcp"
          destination_port_range = "1433"
          source_address_prefix = "10.2.1.0/24"  # Only from web subnet
          destination_address_prefix = "*"
          description          = "Allow SQL from web subnet"
        }
      }
    }
    
    mgmt = {
      address_prefixes = ["10.2.3.0/24"]
      
      # Subnet delegation example
      delegation = {
        name = "Microsoft.Web.serverFarms"
        service_delegation = {
          name = "Microsoft.Web/serverFarms"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/action"
          ]
        }
      }
    }
  }

  tags = {
    Owner       = "Platform Team"
    CostCenter  = "IT-001"
    Environment = "Production"
  }
}
```

### Using Module Outputs

```hcl
# Reference subnet IDs for other resources
resource "azurerm_virtual_machine" "web_vm" {
  # ... other configuration ...
  subnet_id = module.networking.subnet_ids["web"]
}

# Reference NSG for additional rules
resource "azurerm_network_security_rule" "custom_rule" {
  network_security_group_name = module.networking.nsg_names["web"]
  # ... other configuration ...
}

# Get complete network summary
output "network_config" {
  value = module.networking.network_summary
}
```

## Naming Convention

This module follows a standardized naming pattern for all resources:

### Without app_shortcode:
- **VNet**: `{region}-{environment}-{platform_name}-{purpose}-vnet-{instance}`
- **Subnet**: `{region}-{environment}-{platform_name}-{purpose}-snet-{subnet_key}-{instance}`
- **NSG**: `{region}-{environment}-{platform_name}-{purpose}-nsg-{subnet_key}-{instance}`
- **Route Table**: `{region}-{environment}-{platform_name}-{purpose}-rt-{subnet_key}-{instance}`

### With app_shortcode:
- **VNet**: `{region}-{environment}-{platform_name}-{purpose}-{app_shortcode}-vnet-{instance}`
- **Subnet**: `{region}-{environment}-{platform_name}-{purpose}-{app_shortcode}-snet-{subnet_key}-{instance}`
- **NSG**: `{region}-{environment}-{platform_name}-{purpose}-{app_shortcode}-nsg-{subnet_key}-{instance}`
- **Route Table**: `{region}-{environment}-{platform_name}-{purpose}-{app_shortcode}-rt-{subnet_key}-{instance}`

### Example Names:
- VNet: `uks-prod-lss-app-LSH-vnet-02`
- Subnet: `uks-prod-lss-app-LSH-snet-web-02`
- NSG: `uks-prod-lss-app-LSH-nsg-web-02`
- Route Table: `uks-prod-lss-app-LSH-rt-web-02`

## NSG Rules Configuration

NSG rules support all Azure NSG rule properties:

```hcl
nsg_rules = {
  "rule_name" = {
    priority                     = 100                    # Required: 100-4096
    direction                    = "Inbound"              # Required: Inbound/Outbound
    access                       = "Allow"                # Required: Allow/Deny
    protocol                     = "Tcp"                  # Required: Tcp/Udp/Icmp/*
    source_port_range            = "*"                    # Optional: default "*"
    destination_port_range       = "80"                   # Optional: single port
    destination_port_ranges      = ["80", "443"]          # Optional: multiple ports
    source_address_prefix        = "Internet"             # Optional: single CIDR/tag
    source_address_prefixes      = ["10.0.0.0/8"]        # Optional: multiple CIDRs
    destination_address_prefix   = "*"                    # Optional: single CIDR/tag
    destination_address_prefixes = ["10.1.0.0/16"]       # Optional: multiple CIDRs
    description                  = "Rule description"      # Optional: documentation
  }
}
```

## Route Table Configuration

Routes support all Azure route properties:

```hcl
routes = {
  "route_name" = {
    address_prefix         = "0.0.0.0/0"                 # Required: destination CIDR
    next_hop_type          = "VirtualAppliance"           # Required: see next_hop_types
    next_hop_in_ip_address = "10.0.0.100"               # Optional: required for VirtualAppliance
  }
}
```

### Supported Next Hop Types:
- `VirtualNetworkGateway` - Route to VPN/ExpressRoute gateway
- `VnetLocal` - Route within the virtual network
- `Internet` - Route to Internet
- `VirtualAppliance` - Route to network virtual appliance (requires next_hop_in_ip_address)
- `None` - Drop traffic

## Default Tags

The module automatically applies the following tags:
- Environment (from variable)
- Department: "TechOps"
- Source: "terraform"
- CreatedDate: Current date in DD-MM-YYYY format
- ExpiryDate: 3 years from creation
- Project: "CoreServices"
- CostCenter: "TBC"
- RFC: "TBC"

Additional tags can be provided via the `tags` variable and will be merged with the defaults.
