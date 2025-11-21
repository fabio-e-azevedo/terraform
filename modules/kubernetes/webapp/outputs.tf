output "service_ip" {
  description = "O IP externo do Load Balancer"
  # O try evita erro se o IP ainda não tiver sido alocado
  value = try(kubernetes_service.this.status.0.load_balancer.0.ingress.0.ip, "Pendente")
}