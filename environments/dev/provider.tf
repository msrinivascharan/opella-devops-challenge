# environments/dev/provider.tf

terraform {
  required_version = ">= 1.3" # Specify a reasonable minimum version

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Use a specific major version
    }
  }
}

provider "azurerm" {
  features {}

  # Terraform will automatically use credentials from Azure CLI (`az login`),
  # Environment Variables, or Managed Identity / Service Principal.
  # Avoid hardcoding credentials here.
}