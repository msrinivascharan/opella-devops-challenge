terraform {
  backend "azurerm" {
    resource_group_name  = "rg-test-2"
    storage_account_name = "tfstateopella120425"
    container_name       = "tfstate"
    key                  = "terraform.tfstate" # Path to state file inside the container


  # Add these for Service Principal authentication
    tenant_id            = var.tenant_id
    client_id            = var.client_id
    client_secret        = var.client_secret


  }
}