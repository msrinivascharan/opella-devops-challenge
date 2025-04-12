# environments/dev/main.tf

locals {
  # Define common values and naming conventions
  resource_group_name  = lower("${var.resource_group_name_prefix}-${var.environment}-${var.location}-rg")
  vnet_name            = lower("${var.resource_group_name_prefix}-${var.environment}-${var.location}-vnet")
  storage_account_name = lower("${var.resource_group_name_prefix}${var.environment}${var.location}sa") # Must be globally unique, no hyphens
  vm_name              = lower("${var.resource_group_name_prefix}-${var.environment}-${var.location}-vm")
  nic_name             = lower("${var.resource_group_name_prefix}-${var.environment}-${var.location}-nic")
  public_ip_name       = lower("${var.resource_group_name_prefix}-${var.environment}-${var.location}-pip")

  common_tags = {
    Environment = var.environment
    Project     = "OpellaChallenge"
    ManagedBy   = "Charan MS"
    Region      = var.location
  }
}

# --- Core Infrastructure ---

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# --- Networking (using the module) ---

module "network" {
  source = "../../modules/vnet" # Relative path to the module

  vnet_name           = local.vnet_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = var.vnet_address_space
  subnets             = var.vnet_subnets # Pass the subnet configuration
  tags                = local.common_tags
}

# --- Storage ---

resource "azurerm_storage_account" "main" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard" # Free tier eligible
  account_replication_type = "LRS"      # Locally redundant storage (cheapest)
  tags                     = local.common_tags

  # Enable Hierarchical Namespace for Data Lake Storage Gen2 capabilities (optional, but common)
  is_hns_enabled = true
}

resource "azurerm_storage_container" "example" {
  name                  = "my-example-container"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private" # or "blob", "container"
}


# --- Virtual Machine ---

# Public IP for the VM (Needed for SSH access from internet)
# Consider using Azure Bastion or private connectivity in production for better security.
resource "azurerm_public_ip" "vm_pip" {
  name                = local.public_ip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"   # Or Dynamic
  sku                 = "Standard" # Required for availability zones, generally recommended
  tags                = local.common_tags
}

# Network Interface for the VM
resource "azurerm_network_interface" "vm_nic" {
  name                = local.nic_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.network.subnet_ids["vm_subnet"] # Attach to the 'vm_subnet' created by the module
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
  }

  # Ensure the subnet exists before creating the NIC
  depends_on = [module.network]
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                  = local.vm_name
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = "Standard_B1s" # Free tier eligible size
  admin_username        = var.vm_admin_username
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  tags                  = local.common_tags

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = var.vm_admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" # Or Premium_LRS if needed
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy" # Ubuntu 22.04 LTS
    sku       = "22_04-lts-gen2"               # Use Gen2 where possible
    version   = "latest"
  }

  # Disable password authentication for better security
  disable_password_authentication = true

  # Ensure network components are ready
  depends_on = [azurerm_network_interface.vm_nic]
}