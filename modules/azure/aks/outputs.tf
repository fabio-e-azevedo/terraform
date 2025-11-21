output "cluster_id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

# Precisamos destas credenciais para o Provider Kubernetes na raiz
output "kube_config" {
  value     = azurerm_kubernetes_cluster.this.kube_config[0]
  sensitive = true
}

# Output importante: O comando para conectar no cluster depois
output "command_get_credentials" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.this.name} --name ${azurerm_kubernetes_cluster.this.name} --admin"
}
