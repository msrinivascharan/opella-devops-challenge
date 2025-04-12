# environments/dev/variables.tf

variable "environment" {
  description = "The deployment environment name (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "The Azure region to deploy resources into."
  type        = string
  default     = "eastus" # Example default, override in .tfvars
}

variable "resource_group_name_prefix" {
  description = "Prefix for the resource group name."
  type        = string
  default     = "opella"
}

variable "vm_admin_username" {
  description = "Admin username for the Virtual Machine."
  type        = string
  default     = "azureuser"
}

variable "vm_admin_ssh_public_key" {
  description = "SSH public key for authenticating to the VM."
  type        = string
  sensitive   = true # Mark as sensitive, avoid showing in plan output
  # No default - should be provided securely
}



variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}

# --- VNET Module Specific Variables ---
# We can define defaults here or rely solely on terraform.tfvars

variable "vnet_address_space" {
  description = "Address space for the DEV VNET."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "vnet_subnets" {
  description = "Subnet configuration for the DEV VNET."
  type = map(object({
    address_prefix = string
    nsg_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string, "*")
      source_address_prefix      = optional(string, "*")
      destination_address_prefix = optional(string, "*")
    })), [])
  }))
  default = {
    "default" = { # Example subnet
      address_prefix = "10.10.1.0/24"
      nsg_rules      = [] # No custom rules for this example subnet
    },
    "vm_subnet" = { # Subnet for the VM
      address_prefix = "10.10.2.0/24"
      nsg_rules = [
        {
          name                       = "AllowSSHInbound"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*" # WARNING: In production, restrict this to specific IPs!
          destination_address_prefix = "*"
        }
      ]
    }
  }
}