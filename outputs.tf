output "nsg" {
  description = "A map of objects representing network security groups with the associated subnet name as its key."
  value = { for nsg_key in keys(azurerm_network_security_group.this) :
    nsg_key => {
      id       = azurerm_network_security_group.this[nsg_key].id
      name     = azurerm_network_security_group.this[nsg_key].name
      location = azurerm_network_security_group.this[nsg_key].location
      tags     = azurerm_network_security_group.this[nsg_key].tags

      security_rules = { for nsgsr_key in keys(azurerm_network_security_rule.this) :
        nsgsr_key => {
          id                         = azurerm_network_security_rule.this[nsgsr_key].id
          name                       = azurerm_network_security_rule.this[nsgsr_key].name
          access                     = azurerm_network_security_rule.this[nsgsr_key].access
          description                = azurerm_network_security_rule.this[nsgsr_key].description
          destination_address_prefix = azurerm_network_security_rule.this[nsgsr_key].destination_address_prefix
          destination_port_range     = azurerm_network_security_rule.this[nsgsr_key].destination_port_range
          direction                  = azurerm_network_security_rule.this[nsgsr_key].direction
          priority                   = azurerm_network_security_rule.this[nsgsr_key].priority
          protocol                   = azurerm_network_security_rule.this[nsgsr_key].protocol
          source_address_prefix      = azurerm_network_security_rule.this[nsgsr_key].source_address_prefix
          source_port_range          = azurerm_network_security_rule.this[nsgsr_key].source_port_range

          destination_address_prefixes = (azurerm_network_security_rule.this[nsgsr_key].destination_address_prefixes != null
            ? azurerm_network_security_rule.this[nsgsr_key].destination_address_prefixes
            : []
          )

          destination_application_security_group_ids = (azurerm_network_security_rule.this[nsgsr_key].destination_application_security_group_ids != null
            ? azurerm_network_security_rule.this[nsgsr_key].destination_application_security_group_ids
            : []
          )

          destination_port_ranges = (azurerm_network_security_rule.this[nsgsr_key].destination_port_ranges != null
            ? azurerm_network_security_rule.this[nsgsr_key].destination_port_ranges
            : []
          )

          source_address_prefixes = (azurerm_network_security_rule.this[nsgsr_key].source_address_prefixes != null
            ? azurerm_network_security_rule.this[nsgsr_key].source_address_prefixes
            : []
          )

          source_application_security_group_ids = (azurerm_network_security_rule.this[nsgsr_key].source_application_security_group_ids != null
            ? azurerm_network_security_rule.this[nsgsr_key].source_application_security_group_ids
            : []
          )

          source_port_ranges = (azurerm_network_security_rule.this[nsgsr_key].source_port_ranges != null
            ? azurerm_network_security_rule.this[nsgsr_key].source_port_ranges
            : []
          )
        } if azurerm_network_security_rule.this[nsgsr_key].network_security_group_name == azurerm_network_security_group.this[nsg_key].name
      }
    }
  }
}

output "snet" {
  description = "A map of objects representing subnets with the subnet name as its key."
  value = { for key in keys(azurerm_subnet.this) :
    key => {
      id                  = azurerm_subnet.this[key].id
      name                = azurerm_subnet.this[key].name
      resource_group_name = azurerm_subnet.this[key].resource_group_name

      address_prefixes     = azurerm_subnet.this[key].address_prefixes
      virtual_network_name = azurerm_subnet.this[key].virtual_network_name

      network_security_group_id = (contains(keys(azurerm_network_security_group.this), key)
        ? azurerm_network_security_group.this[key].id
        : null
      )

      service_endpoints = (azurerm_subnet.this[key].service_endpoints != null
        ? azurerm_subnet.this[key].service_endpoints
        : []
      )
    }
  }
}

output "vnet" {
  description = "An object representing the virtual network."
  value = {
    id                  = azurerm_virtual_network.this.id
    name                = azurerm_virtual_network.this.name
    resource_group_name = azurerm_virtual_network.this.resource_group_name
    location            = azurerm_virtual_network.this.location
    tags                = azurerm_virtual_network.this.tags

    address_space = azurerm_virtual_network.this.address_space
    guid          = azurerm_virtual_network.this.guid
  }
}
