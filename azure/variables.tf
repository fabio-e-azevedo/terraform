variable "prefix" {
  type = "string"
  default = "ramones"
}

variable "node_count" {
  type = "string"
  default = 3
}

variable "start_number" {
  default = 3
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
