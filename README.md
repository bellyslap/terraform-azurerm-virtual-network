# AzureRM Virtual Network

[![MIT License](https://img.shields.io/badge/License-MIT-brightgreen)](LICENSE)
[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-blue)](https://registry.terraform.io/modules/bellyslap/virtual-network/azurerm/latest)

A Terraform module designed to provision/manage an Azure virtual network, its subnets, and network security groups (NSGs).

## Contents

- [Features](#features)
- [Requirements](#requirements)
- [Argument Reference](#argument-reference)
- [Attributes Reference](#attributes-reference)
- [Example Usage](#example-usage)
- [Known Issues](#known-issues)

## Features

- In order to immediately enforce and control network traffic rules for a subnet, its NSG is always provisioned _before the subnet_.
- A "deny all" inbound/outbound network security rule (with priority 4096) is included with each NSG. These are equivalent to the default [DenyAllInBound](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview#denyallinbound) and [DenyAllOutBound](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview#denyalloutbound) rules that Azure includes with each NSG _but with a higher priority_.

## Requirements

|Name|Version|
|---|---|
|Terraform|>= 0.14
|AzureRM|~> 2.0

## Argument Reference

The following arguments are supported:

- `name` - (Required) Specifies the name of the application, workload, or service that the virtual network is a part of. Changing this forces a new resource to be created.

- `resource_group_name` - (Required) Species the name of the resource group in which to create the resources. Changing this forces new resources to be created.

- `separator` - (Optional) Specifies the string separating the components of the resource names. Defaults to `-`.

- `tags` - "(Optional) Specifies a mapping of tags to assign to the resources.

- `environment` - (Optional) Specifies the stage of the development lifecycle for the workload that the resources support. Defaults to `dev`. Changing this forces a new resource to be created.

- `virtual_network` - (Required) Specifies a `virtual_network` block as defined below.

- `subnets` - (Optional) Specifies the list of `subnet` blocks as defined below.

- `network_security_groups` - (Optional) Specifies the list of `network_security_group` blocks as defined below.

---

A `virtual_network` block supports the following:

- `address_spaces` - (Required) Specifies the list of one or more address spaces used by the virtual network.

- `bgp_community` - (Optional) Specifies the BGP community attribute in format `<as-number>:<community-value>`.

  ---

  Note: The `as-number` segment is the Microsoft ASN, which is always `12076` for now.

  ---

- `ddos_protection_plan` - (Optional) Specifies a `ddos_protection_plan` block as defined below.

- `dns_servers` - (Optional) Specifies the list of IP addresses of DNS servers.

- `flow_timeout_in_minutes` - (Optional) Specifies the flow timeout in minutes for the virtual network, which is used to enable connection tracking for intra-VM flows. Possible values are between `4` and `30` minutes.

---

A `ddos_protection_plan` block supports the following:

- `id` - (Required) Specifies the ID of DDoS Protection Plan.

- `enable` -  (Required) Specifies whether to enable/disable DDoS Protection Plan on the virtual network.

---

A `subnet` block supports the following:

- `name` - (Required) Specifies the name of the subnet. Changing this forces a new resource to be created.

- `address_prefixes` - (Required) Specifies the address prefixes to use for the subnet.

- `delegations` - (Optional) Specifies the list of `delegation` blocks as defined below.

- `enforce_private_link_endpoint_network_policies` - (Optional) Specifies whether to enable/disable network policies for the private link endpoint on the subnet. Setting this to `true` will _disable_ the policy and setting this to `false` will _enable_ the policy. Defaults to `false`. Conflicts with `enforce_private_link_service_network_policies`.

  ---

  Note: Network policies, like network security groups (NSGs), are not supported for Private Link Endpoints or Private Link Services. In order to deploy a Private Link Endpoint on a given subnet, you must set the `enforce_private_link_endpoint_network_policies` attribute to `true`. This setting is only applicable for the Private Link Endpoint.

  ---

- `enforce_private_link_service_network_policies` - (Optional) Specifies whether to enable/disablee network policies for the private link service on the subnet. Setting this to `true` will _disable_ the policy and setting this to `false` will _enable_ the policy. Defaults to `false`. Conflicts with `enforce_private_link_endpoint_network_policies`.

  ---

  Note: In order to deploy a Private Link Service on a given subnet, you must set the `enforce_private_link_service_network_policies` attribute to `true`. This setting is only applicable for the Private Link Service

  ---

- `service_endpoints` - (Optional) Specifies the list of service endpoints to associate with the subnet. Possible values include: `Microsoft.AzureActiveDirectory`, `Microsoft.AzureCosmosDB`, `Microsoft.ContainerRegistry`, `Microsoft.EventHub`, `Microsoft.KeyVault`, `Microsoft.ServiceBus`, `Microsoft.Sql`, `Microsoft.Storage` and `Microsoft.Web`.

- `service_endpoint_policy_ids` - (Optional) Specifies the list of IDs of service endpoint policies to associate with the subnet.

---

A `delegation` block supports the following:

- `name` - (Required) Specifies the name for the delegation.

- `service_delegation` - (Required) Specifies a `service_delegation` block as defined below.

---

A `service_delegation` block supports the following:

- `name` - (Required) Specifies the name of service to delegate to. Possible values include `Microsoft.ApiManagement/service`, `Microsoft.AzureCosmosDB/clusters`, `Microsoft.BareMetal/AzureVMware`, `Microsoft.BareMetal/CrayServers`, `Microsoft.Batch/batchAccounts`, `Microsoft.ContainerInstance/containerGroups`, `Microsoft.ContainerService/managedClusters`, `Microsoft.Databricks/workspaces`, `Microsoft.DBforMySQL/flexibleServers`, `Microsoft.DBforMySQL/serversv2`, `Microsoft.DBforPostgreSQL/flexibleServers`, `Microsoft.DBforPostgreSQL/serversv2`, `Microsoft.DBforPostgreSQL/singleServers`, `Microsoft.HardwareSecurityModules/dedicatedHSMs`, `Microsoft.Kusto/clusters`, `Microsoft.Logic/integrationServiceEnvironments`, `Microsoft.MachineLearningServices/workspaces`, `Microsoft.Netapp/volumes`, `Microsoft.Network/managedResolvers`, `Microsoft.PowerPlatform/vnetaccesslinks`, `Microsoft.ServiceFabricMesh/networks`, `Microsoft.Sql/managedInstances`, `Microsoft.Sql/servers`, `Microsoft.StreamAnalytics/streamingJobs`, `Microsoft.Synapse/workspaces`, `Microsoft.Web/hostingEnvironments`, and `Microsoft.Web/serverFarms`.

- `actions` - (Optional) Specifies the list of actions which should be delegated. This list is specific to the service to delegate to. Possible values include `Microsoft.Network/networkinterfaces/*`, `Microsoft.Network/virtualNetworks/subnets/action`, `Microsoft.Network/virtualNetworks/subnets/join/action`, `Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action` and `Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action`.

  ---

  Note: `actions` are specific to each service type. The exact list of `actions` can be retrieved using [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az_network_vnet_subnet_list_available_delegations).

  Note: Azure may add default actions depending on the service delegation name that can't be changed.

---

A `network_security_group` block supports the following:

- `subnets` - (Required) Specifies a list of subnet names to be associated with the neteork security group.

- `security_rules` - (Optional) Specifies a list of `security_rule` blocks representing security rules as defined below.

---

A `security_rule` block supports the following:

- `name` - (Required) Specifies the name of the security rule. This needs to be unique across all rules in the network security group. Changing this forces a new resource to be created.

- `access` - (Required) Specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`.

- `description` - (Required) Specifies a description of the security rule. Restricted to 140 characters.

- `destination_address_prefix` - (Required*) Specifies the CIDR or destination IP range or `*` to match any IP. Tags such as `VirtualNetwork`, `AzureLoadBalancer` and `Internet` can also be used. Also supports all available Service Tags like `Sql.WestEurope`, `Storage.EastUS`, etc. The list of available service tags can be retrieved using [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/network?view=azure-cli-latest#az_network_list_service_tags). This is required if `destination_address_prefixes` is not specified.

- `destination_address_prefixes` - (Required*) Specifies the list of destination address prefixes. Tags may not be used. This is required if `destination_address_prefix` is not specified.

- `destination_application_security_group_ids` - (Required*) Specifies the list of destination application security group IDs.

- `destination_port_range` - (Required*) Specifies the destination port or range. Integer or range between `0` and `65535` or `*` to match any. This is required if `destination_port_ranges` is not specified.

- `direction` - (Required) Specifies the direction that the security rule will be evaluated. Possible values are `Inbound` and `Outbound`.

- `priority` - (Required) Specifies the priority of the security rule. The value can be between `100` and `4095`. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule.

  ---

  Note: A "deny all" security rule with `priority = 4096` for both inbound and outbound is included with each network security group.

  ---

- `protocol` - (Required) Specifies the network protocol the security rule applies to. Possible values include `Tcp`, `Udp`, `Icmp`, `Esp`, `Ah` or `*` (which matches all).

- `source_address_prefix` - (Required*) Specifies the CIDR or source IP range or `*` to match any IP. Tags such as `VirtualNetwork`, `AzureLoadBalancer` and `Internet` can also be used. This is required if `source_address_prefixes` is not specified.

- `source_address_prefixes` - (Required*) Specifies the list of source address prefixes. Tags may not be used. This is required if `source_address_prefix` is not specified.

- `source_application_security_group_ids` - (Required*) Specifies the list of source application security group IDs.

- `source_port_range` - (Required*) Specifies the source port or range. Integer or range between `0` and `65535` or `*` to match any. This is required if `source_port_ranges` is not specified.

- `source_port_ranges` - (Required*) Specifies the list of source ports or port ranges. This is required if `source_port_range` is not specified.

## Attributes Reference

The following attributes are exported:

- `vnet` - A `vnet` block as defined below.

- `snet` - A map of `snet` blocks representing a subnet as defined below _where the subnet name is its key_.

- `nsg` - A map of `snet` blocks representing a network security group as defined below _where the network security group name is its key_.

---

The `vnet` block exports:

- `id` - The ID of the virtual network.

- `name` - The name of the virtual network.

- `resource_group_name` - The name of the resource group in which the virtual network is created.

- `location` - The location/region where the virtual network is created.

- `tags` -  The mapping of tags to assigned to the virtual network.

- `address_space` - The list of address spaces used by the virtual network.

- `guid` - The GUID of the virtual network.

---

An `snet` block exports:

- `id` - The ID of the subnet.

- `name` - The name of the subnet.

- `resource_group_name` - The name of the resource group the virtual network is located in.

- `address_prefixes` - The address prefixes for the subnet.

- `network_security_group_id` - The ID of the network security group associated with the subnet.

- `service_endpoints` - The list of service endpoints within the subnet.

- `virtual_network_name` - The name of the virtual network the subnet is located within.

---

An `nsg` block exports:

- `id` - The ID of the network security group.

- `name` - The name of the network security group.

- `location` - The location/region where the network security group is created.

- `tags` -  The mapping of tags to assigned to the network security group.

- `security_rules` - A map of `security_rule` blocks representing a security rule as defined below _where the associated subnet and the security rule name is its key_.

---

A `security_rule` block exports:

- `id` - The ID of the network security rule.

- `name` - The name of the security rule.

- `access` - Indicate whether network traffic is allowed or denied

- `description` - The description of the security rule.

- `destination_address_prefix` - The CIDR or destination IP range or `*` to match any IP.

- `destination_address_prefixes` - The list of destination address prefixes.

- `destination_application_security_group_ids` -The list of destination application security group IDs.

- `destination_port_range` - The destination port or range.

- `direction` - The direction that the rule is evaluated.

- `priority` - The priority of the rule.

- `protocol` - The network protocol the security rule applies to.

- `source_address_prefix` - The CIDR or source IP range or `*` to match any IP.

- `source_address_prefixes` -The list of source address prefixes.

- `source_application_security_group_ids` - The list of source application security group IDs.

- `source_port_range` - The source port or range.

- `source_port_ranges` - The list of source ports or port ranges.

## Example Usage

```hcl
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
```

## Known Issues

- A Terraform _"inconsistent list element types"_ crash occurs when the `security_rule` arguments corresponding to the [`azurerm_network_security_rule`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) resource are made _optional_ (e.g. `description`, `source_address_prefix`, `source_address_prefixes`, etc). As a workaround, these arguments are _required_ while this issue is investigated. Set an argument value to `null` if it's not needed for the security rule.
