locals {
  nsgs = flatten([for nsg in(var.network_security_groups != null ? var.network_security_groups : []) :
    [for subnet in nsg.subnets :
      {
        subnet         = subnet
        security_rules = concat(local.deny_all_nsgsrs, nsg.security_rules != null ? nsg.security_rules : [])
      } if contains(var.subnets[*].name, subnet) # Only consider NSGs for defined subnets.
    ]
  ])

  nsgsrs = flatten([for nsg in local.nsgs :
    [for security_rule in nsg.security_rules != null ? nsg.security_rules : [] :
      {
        key    = format("%s-%s", nsg.subnet, security_rule.name)
        subnet = nsg.subnet
        rule   = security_rule
      }
    ]
  ])

  subnets = { for subnet in var.subnets :
    subnet.name => subnet
  }

  deny_all_nsgsrs = [
    {
      name                                       = "DenyAllInBound"
      access                                     = "Deny"
      description                                = null
      destination_address_prefix                 = "*"
      destination_address_prefixes               = null
      destination_application_security_group_ids = null
      destination_port_range                     = "*"
      destination_port_ranges                    = null
      direction                                  = "Inbound"
      priority                                   = 4096
      protocol                                   = "*"
      source_address_prefix                      = "*"
      source_address_prefixes                    = null
      source_application_security_group_ids      = null
      source_port_range                          = "*"
      source_port_ranges                         = null
    },
    {
      name                                       = "DenyAllOutBound"
      access                                     = "Deny"
      description                                = null
      destination_address_prefix                 = "*"
      destination_address_prefixes               = null
      destination_application_security_group_ids = null
      destination_port_range                     = "*"
      destination_port_ranges                    = null
      direction                                  = "Outbound"
      priority                                   = 4096
      protocol                                   = "*"
      source_address_prefix                      = "*"
      source_address_prefixes                    = null
      source_application_security_group_ids      = null
      source_port_range                          = "*"
      source_port_ranges                         = null
    }
  ]
}