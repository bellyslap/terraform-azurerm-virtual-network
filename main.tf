#
# Network Security Groups
#

module "nsg_name" {
  for_each      = local.subnets
  source        = "bellyslap/resource-name/azurerm"
  version       = "0.0.4-beta"
  name          = format("%s%s%s", var.name, var.separator, each.key)
  location      = data.azurerm_resource_group.this.location
  resource_type = "Network Security Group"
  environment   = var.environment
  separator     = var.separator
}

resource "azurerm_network_security_group" "this" {
  for_each            = { for nsg in local.nsgs : nsg.subnet => nsg }
  name                = module.nsg_name[each.key].name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  tags                = var.tags
}

#
# Network Security Rules
#

resource "azurerm_network_security_rule" "this" {
  for_each                    = { for nsgsr in local.nsgsrs : nsgsr.key => nsgsr }
  name                        = each.value.rule.name
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.this[each.value.subnet].name

  access                                     = each.value.rule.access
  description                                = each.value.rule.description
  destination_address_prefix                 = each.value.rule.destination_address_prefix
  destination_address_prefixes               = each.value.rule.destination_address_prefixes
  destination_application_security_group_ids = each.value.rule.destination_application_security_group_ids
  destination_port_range                     = each.value.rule.destination_port_range
  destination_port_ranges                    = each.value.rule.destination_port_ranges
  direction                                  = each.value.rule.direction
  priority                                   = each.value.rule.priority
  protocol                                   = each.value.rule.protocol
  source_address_prefix                      = each.value.rule.source_address_prefix
  source_address_prefixes                    = each.value.rule.source_address_prefixes
  source_application_security_group_ids      = each.value.rule.source_application_security_group_ids
  source_port_range                          = each.value.rule.source_port_range
  source_port_ranges                         = each.value.rule.source_port_ranges
}

#
# Virtual Network
#

module "vnet_name" {
  source        = "bellyslap/resource-name/azurerm"
  version       = "0.0.4-beta"
  name          = var.name
  resource_type = "Virtual Network"
  location      = data.azurerm_resource_group.this.location
  environment   = var.environment
  separator     = var.separator
}

resource "azurerm_virtual_network" "this" {
  name                = module.vnet_name.name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  tags                = var.tags

  address_space           = var.virtual_network.address_spaces
  bgp_community           = var.virtual_network.bgp_community
  dns_servers             = var.virtual_network.dns_servers
  flow_timeout_in_minutes = var.virtual_network.flow_timeout_in_minutes

  dynamic "ddos_protection_plan" {
    for_each = var.virtual_network.ddos_protection_plan != null ? [var.virtual_network.ddos_protection_plan] : []
    content {
      id     = ddos_protection_plan.value["id"]
      enable = ddos_protection_plan.value["enable"]
    }
  }
}

#
# Subnets
# 

module "snet_name" {
  for_each      = local.subnets
  source        = "bellyslap/resource-name/azurerm"
  version       = "0.0.4-beta"
  name          = each.key
  resource_type = "Subnet"
  environment   = var.environment
  separator     = var.separator
}

resource "azurerm_subnet" "this" {
  depends_on = [
    azurerm_network_security_rule.this # Ensure the NSGs and their rules already exist.
  ]

  for_each            = local.subnets
  name                = module.snet_name[each.key].name
  resource_group_name = data.azurerm_resource_group.this.name

  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints
  virtual_network_name = azurerm_virtual_network.this.name

  dynamic "delegation" {
    for_each = each.value.delegations != null ? each.value.delegations : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

#
# Subnets/NSG Associations
# 

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = toset(keys(azurerm_network_security_group.this))
  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}