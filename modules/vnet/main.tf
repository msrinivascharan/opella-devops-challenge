# modules/vnet/main.tf

# Create the Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags

  # Optional DDoS Protection
  #ddos_protection_plan {
    #id     = null # Specify a DDoS Plan ID if var.enable_ddos_protection is true (requires creating/referencing the plan outside the module typically)
    #enable = var.enable_ddos_protection
  #}

  #lifecycle {
    #ignore_changes = [
      # Ignore changes to DDoS settings if not explicitly enabled/managed by this module run
      #ddos_protection_plan,
    #]
  #}
}

# Create Network Security Groups for each subnet that defines rules
resource "azurerm_network_security_group" "subnet_nsg" {
  # Create an NSG only if the subnet definition includes nsg_rules
  for_each = { for k, v in var.subnets : k => v if length(v.nsg_rules) > 0 }

  name                = "${var.vnet_name}-${each.key}-nsg" # e.g., myvnet-web-nsg
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, { "AssociatedSubnet" = each.key })

  dynamic "security_rule" {
    # Iterate over the nsg_rules defined for the current subnet in the loop
    for_each = each.value.nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

# Create Subnets
resource "azurerm_subnet" "main" {
  for_each = var.subnets

  name                 = each.key # Use the map key as the subnet name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.address_prefix]
}

# Associate NSGs with Subnets (only if an NSG was created for that subnet)
resource "azurerm_subnet_network_security_group_association" "main" {
  # Use the same condition as NSG creation
  for_each = { for k, v in var.subnets : k => v if length(v.nsg_rules) > 0 }

  subnet_id                 = azurerm_subnet.main[each.key].id
  network_security_group_id = azurerm_network_security_group.subnet_nsg[each.key].id

  # Explicit dependency to ensure subnet exists before association
  depends_on = [azurerm_subnet.main]
}