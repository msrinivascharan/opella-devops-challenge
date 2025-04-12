terraform {
  backend "azurerm" {
    resource_group_name  = "rg-test-2"
    storage_account_name = "tfstateopella120425"
    container_name       = "tfstate"
    key                  = "terraform.tfstate" # Path to state file inside the container
  }
}