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
    akssubnet                = cidrsubnet(var.vnet_address_space, 2, 1)
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

module "acr" {
  source              = "./modules/azurerm_azure_container_registry"
  acr_name            = "acr${var.application_name}${var.environment}"
  resource_group_name = module.rg.resource_group_name
  location            = var.primary_location
}

module "aks" {
  source              = "./modules/azurerm_azure_kubernetes_cluster"
  cluster_name        = "aks-${var.application_name}-${var.environment}"
  resource_group_name = module.rg.resource_group_name
  location            = module.rg.location
  subnet_id           = module.snet["akssubnet"].subnet_id
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.aks_kubelet_identity_object_id

}

data "azurerm_key_vault" "existing_kv" {
  name                = "kv-digwi-shared"
  resource_group_name = "rg-digwi-shared-kv"
}

data "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  key_vault_id = data.azurerm_key_vault.existing_kv.id
}

module "sql_server" {
  source                       = "./modules/azurerm_mssql_server"
  sql_server_name              = "sqlserver${var.application_name}${var.environment}"
  resource_group_name          = module.rg.resource_group_name
  location                     = module.rg.location
  administrator_login          = "sqladminuser"
  administrator_login_password = data.azurerm_key_vault_secret.sql_admin_password.value
}

module "sql_db" {
  source        = "./modules/azurerm_mssql_database"
  database_name = "sqldb-${var.application_name}-${var.environment}"
  sql_server_id = module.sql_server.sql_server_id
}

