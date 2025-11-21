provider "azurerm" {
  features {}
  # export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
  resource_provider_registrations = "none"
}

module "cluster_aks" {
  source          = "./modules/azure/aks"
  prefixo         = "lab-pro"
  localizacao     = "East US"
  node_count      = 1
}

# --- CONFIGURAÇÃO DO PROVIDER KUBERNETES ---
# (Isso conecta o Módulo 1 ao Módulo 2)
provider "kubernetes" {
  host                   = module.cluster_aks.kube_config.host
  client_certificate     = base64decode(module.cluster_aks.kube_config.client_certificate)
  client_key             = base64decode(module.cluster_aks.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.cluster_aks.kube_config.cluster_ca_certificate)
}

# MÓDULO DE APLICAÇÃO (Reutilizável!)
module "app_nginx" {
  source = "./modules/kubernetes/webapp"

  # Dependência explícita: Só crie o app se o cluster existir
  depends_on = [module.cluster_aks]

  name_app     = "nginx-app"
  docker_image = "nginx:latest"
  replicas     = 2
}

# --- Output do IP ---
output "app_nginx_service_ip" {
  value = module.app_nginx.service_ip
}