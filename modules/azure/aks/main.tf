terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.54.0"
    }
  }
}

resource "azurerm_resource_group" "this" {
  name     = "${var.prefixo}-resources"
  location = var.localizacao
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = "${var.prefixo}-aks"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = "${var.prefixo}-k8s"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  # Identidade (Permissões de acesso do cluster)
  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Lab"
    Source      = "Terraform Module"
  }
}
