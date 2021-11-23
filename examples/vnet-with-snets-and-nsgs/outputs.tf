output "nsg" {
  description = "A map of objects representing network security groups with the associated subnet name as its key."
  value       = module.network.nsg
}

output "snet" {
  description = "A map of objects representing subnets with the subnet name as its key."
  value       = module.network.nsg
}

output "vnet" {
  description = "An object representing the virtual network."
  value       = module.network.nsg
}

