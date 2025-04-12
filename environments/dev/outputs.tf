# environments/dev/outputs.tf

output "resource_group_name" {
  description = "Name of the development resource group."
  value       = azurerm_resource_group.main.name
}

output "vnet_name" {
  description = "Name of the VNET deployed in the dev environment."
  value       = module.network.vnet_name
}

output "dev_vm_public_ip" {
  description = "Public IP address of the development VM."
  value       = azurerm_public_ip.vm_pip.ip_address
  # Potentially sensitive, consider if this should be outputted depending on security policy
}

output "dev_vm_private_ip" {
  description = "Private IP address of the development VM NIC."
  value       = azurerm_network_interface.vm_nic.private_ip_address
}

output "dev_storage_account_name" {
  description = "Name of the development storage account."
  value       = azurerm_storage_account.main.name
}

output "dev_vm_ssh_command" {
  description = "Command to SSH into the dev VM (replace placeholder with your private key path)."
  value       = format("ssh -i %s %s@%s", "<path_to_private_key>", var.vm_admin_username, azurerm_public_ip.vm_pip.ip_address)
  # Sensitive set to false as it contains the public IP and username, but needs user input for the key path
}