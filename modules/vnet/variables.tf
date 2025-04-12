# modules/vnet/variables.tf

variable "vnet_name" {
  description = "Name of the Virtual Network."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where resources will be created."
  type        = string
}

variable "location" {
  description = "Azure region where the resources will be deployed."
  type        = string
}

variable "address_space" {
  description = "The address space for the Virtual Network (e.g., [\"10.0.0.0/16\"])."
  type        = list(string)
}

variable "subnets" {
  description = "A map of subnets to create. Key is the subnet name, value is an object with address_prefix and optional nsg_rules."
  type = map(object({
    address_prefix = string
    # Optional: Define NSG rules for this specific subnet
    nsg_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string # Inbound or Outbound
      access                     = string # Allow or Deny
      protocol                   = string # Tcp, Udp, Icmp, *
      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string, "*")
      source_address_prefix      = optional(string, "*")
      destination_address_prefix = optional(string, "*")
    })), []) # Default to empty list if not provided
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to apply to all resources created by this module."
  type        = map(string)
  default     = {}
}

variable "enable_ddos_protection" {
  description = "Enable Azure DDoS Network Protection Plan on the VNET."
  type        = bool
  default     = false # Keep costs down for the challenge, default to false
}