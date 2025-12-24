variable "hostname" {
  type = string
}

variable "memory" {
  type = number
}

variable "vcpu" {
  type = number
}

variable "private_ip" {
  type = string
}

variable "ssh_key" {
  type = string
}

variable "base_volume_id" {
  type = string
}

variable "pool" {
  type    = string
  default = "default"
}

variable "private_network_id" {
  type = string
}

variable "public_network_name" {
  type = string
}

variable "cloud_init_template" {
  type = string
}
