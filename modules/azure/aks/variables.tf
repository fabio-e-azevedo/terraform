variable "prefixo" {
  description = "Prefixo para nomes de recursos"
  type        = string
  default     = "tf-lab"
}

variable "localizacao" {
  description = "Região do Azure"
  type        = string
  default     = "East US"
}

variable "node_count" {
  description = "Quantidade de máquinas no cluster"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "Tamanho da máquina virtual para os nós do cluster"
  type        = string
  default     = "Standard_B2s"
}
