provider "azurerm" {
  features {}
}

module "rg_name" {
  source        = "bellyslap/resource-name/azurerm"
  version       = "0.0.4-beta"
  name          = var.name
  resource_type = "Resource Group"
  location      = var.location
  environment   = var.environment
}

resource "azurerm_resource_group" "this" {
  name     = module.rg_name.name
  location = var.location
  tags     = var.tags
}

module "network" {
  depends_on = [
    azurerm_resource_group.this
  ]

  source              = "bellyslap/virtual-network/azurerm"
  version             = "0.0.1-beta"
  name                = var.name
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags

  environment             = var.environment
  network_security_groups = var.network_security_groups
  subnets                 = var.subnets
  virtual_network         = var.virtual_network
}
