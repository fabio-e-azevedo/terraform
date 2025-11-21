variable "name_app" {
  description = "Nome da aplicação (ex: meu-nginx)"
  type        = string
}

variable "docker_image" {
  description = "Imagem do container (ex: nginx:latest)"
  type        = string
}

variable "replicas" {
  description = "Quantas cópias rodar"
  type        = number
  default     = 2
}

variable "namespace" {
  description = "Namespace onde será feito o deploy"
  type        = string
  default     = "default"
}

variable "limits_cpu" {
  description = "Limite de CPU para o container"
  type        = string
  default     = "0.5"
}

variable "limits_memory" {
  description = "Limite de memória para o container"
  type        = string
  default     = "512Mi"
}

variable "requests_cpu" {
  description = "Requisição de CPU para o container"
  type        = string
  default     = "250m"
}

variable "requests_memory" {
  description = "Requisição de memória para o container"
  type        = string
  default     = "50Mi"
}

variable "container_port" {
  description = "Porta que o container irá expor"
  type        = number
  default     = 80
}