terraform {
  backend "azurerm" {
    resource_group_name  = "orso-global-rg"
    storage_account_name = "orsoglobalsa"
    container_name       = "tfstate"
  }
}

module "resource_group_name" {
  source   = "gsoft-inc/naming/azurerm//modules/general/resource_group"
  name     = "infra"
  prefixes = ["orso", "arpa", "dev"]
  suffixes = ["rg"]
}

module "storage_account_name" {
  source   = "gsoft-inc/naming/azurerm//modules/storage/storage_account"
  name     = "frontend"
  prefixes = ["orso", "arpa", "dev"]
  separator = ""
  suffixes = ["sa"]
}

resource "azurerm_resource_group" "orsoarpadev" {
  name     = module.resource_group_name.result
  location = "Germany West Central"
}

resource "azurerm_storage_account" "orsoarpadev" {
  name                     = module.storage_account_name.result
  resource_group_name      = azurerm_resource_group.orsoarpadev.name
  location                 = azurerm_resource_group.orsoarpadev.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  static_website {
    index_document = "index.html"
    error_404_document = "index.html"
  }

  tags = {
    environment = "dev"
  }
}
