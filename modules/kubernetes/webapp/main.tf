terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.38.0"
    }
  }
}

resource "kubernetes_deployment" "this" {
  metadata {
    name      = var.name_app
    namespace = var.namespace
    labels = {
      app = var.name_app
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.name_app
      }
    }

    template {
      metadata {
        labels = {
          app = var.name_app
        }
      }

      spec {
        container {
          image = var.docker_image
          name  = var.name_app
          resources {
            limits = {
              cpu    = var.limits_cpu
              memory = var.limits_memory
            }
            requests = {
              cpu    = var.requests_cpu
              memory = var.requests_memory
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "this" {
  metadata {
    name      = "${var.name_app}-svc"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = var.name_app
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 80
    }
  }
}