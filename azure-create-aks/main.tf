# 1. Configuração do Terraform e do Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
}

# 2. Variáveis para facilitar a configuração
variable "prefixo" {
  default = "tf-lab"
}

variable "localizacao" {
  default = "East US"
}

# 3. O Resource Group (A "pasta" que agrupa tudo na Azure)
resource "azurerm_resource_group" "this" {
  name     = "${var.prefixo}-resources"
  location = var.localizacao
}

# 4. O Cluster AKS
resource "azurerm_kubernetes_cluster" "this" {
  name                = "${var.prefixo}-aks"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = "${var.prefixo}-k8s"

  # Configuração da máquina (Node Pool)
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s" # Uma máquina pequena e barata para testes
  }

  # Identidade (Permissões de acesso do cluster)
  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Lab"
  }
}

# 5. Output importante: O comando para conectar no cluster depois
output "comando_conexao" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.this.name} --name ${azurerm_kubernetes_cluster.this.name}"
}

# --- Configuração do Provider Kubernetes ---
# Ele usa as credenciais do cluster que acabamos de criar para se autenticar
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.this.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = "app-web"
  }
}

# --- O Deploy do NGINX ---
resource "kubernetes_deployment" "this" {
  metadata {
    name      = "nginx-demo"
    namespace = kubernetes_namespace.this.metadata.0.name
  }

  spec {
    replicas = 2 # Vamos criar 2 réplicas para alta disponibilidade
    selector {
      match_labels = {
        app = "meu-nginx"
      }
    }
    template {
      metadata {
        labels = {
          app = "meu-nginx"
        }
      }
      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# --- O Serviço (Load Balancer) ---
# Isso pede para a Azure criar um IP Público para acessarmos o Nginx
resource "kubernetes_service" "this" {
  metadata {
    name      = "nginx-service"
    namespace = kubernetes_namespace.this.metadata.0.name
  }
  spec {
    selector = {
      app = "meu-nginx" # Conecta com o deployment acima
    }
    type = "LoadBalancer" # A mágica que cria o IP externo
    port {
      port        = 80
      target_port = 80
    }
  }
}

# --- Output do IP ---
output "ip_do_nginx" {
  value = kubernetes_service.this.status.0.load_balancer.0.ingress.0.ip
}
