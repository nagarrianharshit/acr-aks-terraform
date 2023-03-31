resource "azurerm_resource_group" "rg" {
  name     = "aks-acr-rg"
  location = "eastus"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks-name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.aks-name

  default_node_pool {
    name       = "agentpool"
    node_count = 2
    vm_size    = var.aks-node-size
    os_sku = "Ubuntu"
  }
    sku_tier = "Free"
    
  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Dev/test"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw

  sensitive = true
}
resource "azurerm_container_registry" "acr" {
  name                = var.acr-name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.acr-sku
}
resource "azurerm_role_assignment" "role-assignment" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}