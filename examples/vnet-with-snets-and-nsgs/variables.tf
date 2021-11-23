variable "environment" {
  description = "Specifies the stage of the development lifecycle for the workload that the resources support."
  default     = "dev"
}

variable "location" {
  description = "Specifies the Azure region where the resources are deployed."
  default     = "eastus2"
}

variable "name" {
  description = "Specifies the name of the application, workload, or service that the virtual network is a part of."
  default     = "example"
}

variable "network_security_groups" {
  description = "Specifies the list of objects representing the network security groups to enable inbound/outbound traffic to be allowed/denied."
  default = [
    {
      subnets = ["apps1", "apps2"]
      security_rules = [
        {
          name        = "AllowAzFrontDoorBackendInBound"
          description = "Accept traffic from Azure Front Door's backend IP address space."
          access      = "Allow"
          direction   = "Inbound"
          priority    = 100
          protocol    = "Tcp"

          destination_address_prefix                 = "*"
          destination_address_prefixes               = null
          destination_application_security_group_ids = null
          destination_port_range                     = 443
          destination_port_ranges                    = null
          source_address_prefix                      = "AzureFrontDoor.Backend"
          source_address_prefixes                    = null
          source_application_security_group_ids      = null
          source_port_range                          = "*"
          source_port_ranges                         = null
        }
      ]
    },
    {
      subnets = ["data"]
    }
  ]
}

variable "subnets" {
  description = "Specifies the list of objects representing subnets in the virtual network."
  default = [
    {
      name             = "apps1"
      address_prefixes = ["192.168.0.0/24"]
      service_endpoints = [
        "Microsoft.AzureCosmosDB"
      ]
    },
    {
      name             = "apps2"
      address_prefixes = ["192.168.1.0/24"]
      service_endpoints = [
        "Microsoft.AzureCosmosDB"
      ]
    },
    {
      name             = "data"
      address_prefixes = ["192.168.2.0/24"]
      delegations = [
        {
          name = "CosmosDB"
          service_delegation = {
            name = "Microsoft.AzureCosmosDB/clusters"
            actions = [
              "Microsoft.Network/virtualNetworks/subnets/join/action"
            ]
          }
        }
      ]
    }
  ]
}

variable "tags" {
  description = "Specifies a mapping of tags to assign to the resources."
  default = {
    "environment" : "dev"
  }
}

variable "virtual_network" {
  description = "Specifies an object representing the virtual network."
  default = {
    address_spaces = ["192.168.0.0/16"]
  }
}
