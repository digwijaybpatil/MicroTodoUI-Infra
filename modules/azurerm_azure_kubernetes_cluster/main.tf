resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = var.node_vm_size
    vnet_subnet_id  = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

}
