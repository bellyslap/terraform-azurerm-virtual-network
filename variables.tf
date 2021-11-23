variable "environment" {
  description = "(Optional) Specifies the stage of the development lifecycle for the workload that the resources support. Defaults to `dev`."
  type        = string
  default     = "dev"
}

variable "name" {
  description = "(Required) Specifies the name of the application, workload, or service that the virtual network is a part of."
  type        = string
}

variable "network_security_groups" {
  description = "(Optional) Specifies the list of objects representing network security groups to enable inbound/outbound traffic to be allowed/denied."
  type = list(object({
    subnets = list(string)
    security_rules = optional(list(object({
      name = string

      access    = string
      direction = string
      priority  = number
      protocol  = string

      # TODO - Figure out why Terraform crash occurs when these are made optional
      description                                = string       # Should be optional
      destination_address_prefix                 = string       # Should be optional
      destination_address_prefixes               = list(string) # Should be optional
      destination_application_security_group_ids = list(string) # Should be optional
      destination_port_range                     = string       # Should be optional
      destination_port_ranges                    = list(number) # Should be optional
      source_address_prefix                      = string       # Should be optional
      source_address_prefixes                    = list(string) # Should be optional
      source_application_security_group_ids      = list(string) # Should be optional
      source_port_range                          = string       # Should be optional
      source_port_ranges                         = list(number) # Should be optional
    })))
  }))
  default = []
}

variable "resource_group_name" {
  description = "(Required) Species the name of the resource group in which to create the resources. Changing this forces new resources to be created."
}

variable "separator" {
  description = "(Optional) Specifies the string separating the components of the resource names. Defaults to `-`."
  type        = string
  default     = "-"
}

variable "subnets" {
  description = "(Optional) Specifies the list of objects representing subnets in the virtual network."
  type = list(object({
    name                                           = string
    address_prefixes                               = list(string)
    enforce_private_link_endpoint_network_policies = optional(bool)
    enforce_private_link_service_network_policies  = optional(bool)
    service_endpoints                              = optional(list(string))
    service_endpoint_policy_ids                    = optional(list(string))
    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string) # "inconsistent list element types" panic occurs when made optional
      })
    })))
  }))
  default = []
}

variable "tags" {
  description = "(Optional) Specifies a mapping of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "virtual_network" {
  description = "(Required) Specifies an object representing the virtual network."
  type = object({
    address_spaces          = list(string)
    bgp_community           = optional(string)
    dns_servers             = optional(list(string))
    flow_timeout_in_minutes = optional(number)
    ddos_protection_plan = optional(object({
      id     = string
      enable = bool
    }))
  })
}