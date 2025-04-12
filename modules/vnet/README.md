# Terraform Azure VNET Module

This module provisions an Azure Virtual Network (VNET) with configurable subnets and associated Network Security Groups (NSGs).

## Features

- Creates an Azure VNET.
- Dynamically creates subnets based on input map.
- Optionally creates an NSG per subnet with specified rules.
- Associates NSGs with their respective subnets.
- Supports tags for all resources.
- Optional Azure DDoS Protection enabling.

## Usage Example

```hcl
module "networking" {
  source = "../modules/vnet" # Or path from root, or Git URL

  vnet_name           = "my-dev-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.1.0.0/16"]
  tags                = local.common_tags

  subnets = {
    "web" = {
      address_prefix = "10.1.1.0/24"
      nsg_rules = [
        {
          name                       = "AllowSSH"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "YOUR_HOME_IP/32" # Be specific!
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowHTTP"
          priority                   = 110
          # ... other http rules
        }
      ]
    },
    "app" = {
      address_prefix = "10.1.2.0/24"
      # No specific NSG rules defined here, so no NSG will be created for this subnet
    }
  }
}