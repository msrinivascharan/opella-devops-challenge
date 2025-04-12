# modules/vnet/outputs.tf

output "vnet_id" {
  description = "The ID of the created Virtual Network."
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "The Name of the created Virtual Network."
  value       = azurerm_virtual_network.main.name
}

output "vnet_location" {
  description = "The Azure region where the VNET is deployed."
  value       = azurerm_virtual_network.main.location
}

output "subnet_ids" {
  description = "A map of subnet names to their IDs."
  value = { for k, subnet in azurerm_subnet.main : k => subnet.id }
  # Sensitive set to false as IDs are generally not secret, but be mindful
}

output "subnet_address_prefixes" {
  description = "A map of subnet names to their address prefixes."
  value = { for k, subnet in azurerm_subnet.main : k => subnet.address_prefixes }
}

output "nsg_ids" {
  description = "A map of subnet names to the IDs of their associated Network Security Groups (if created)."
  value = { for k, nsg in azurerm_network_security_group.subnet_nsg : k => nsg.id }
  # This output will only contain entries for subnets that had NSGs created.
}