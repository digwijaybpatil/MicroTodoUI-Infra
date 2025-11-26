module "rg" {
  source              = "./modules/azurerm_resource_group"
  resource_group_name = "rg-${var.application_name}-${var.environment}"
  location            = var.primary_location
}

module "vnet" {
  source               = "./modules/azurerm_virtual_network"
  virtual_network_name = "vnet-${var.application_name}-${var.environment}"
  address_space        = [var.vnet_address_space]
  location             = var.primary_location
  resource_group_name  = module.rg.resource_group_name
}

locals {
  subnets = {
    ApplicationGatewaySubnet = cidrsubnet(var.vnet_address_space, 4, 0)
    app                      = cidrsubnet(var.vnet_address_space, 2, 1)
    data                     = cidrsubnet(var.vnet_address_space, 2, 2)
  }
}

module "snet" {
  source               = "./modules/azurerm_subnet"
  for_each             = local.subnets
  subnet_name          = each.key
  resource_group_name  = module.rg.resource_group_name
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = [each.value]
}
