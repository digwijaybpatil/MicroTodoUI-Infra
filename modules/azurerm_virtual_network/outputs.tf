output "virtual_network_name" {
  value = azurerm_virtual_network.main.name
}

output "address_space" {
  value = azurerm_virtual_network.main.address_space
}

output "virtual_network_id" {
  value = azurerm_virtual_network.main.id
}
