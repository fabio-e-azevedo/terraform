variable "prefix" {
  type = "string"
  default = "ramones"
}

variable "node_count" {
  type = "string"
  default = 5
}

variable "start_number" {
  default = 0
}

variable "location" {
  type = "string"
  default = "eastus"
}

variable "username" {
  type = "string"
  default = "admin"
}

variable "password" {
  type = "string"
  default = "superpassword"
}

variable "ip_address" {
  type = "string"
  default = "10.0.9.0/24"
}
