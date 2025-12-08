variable "vms" {
  description = "Конфиг для всех виртуальных машин"
  type = map(object({
    hostname   = string
    memory     = number
    vcpu       = number
    private_ip = string
  }))
}

# опционально, чтобы не хардкодить путь к ключу
variable "ssh_key_path" {
  description = "Путь к публичному SSH ключу"
  type        = string
  default     = "/home/uadmin/.ssh/id_ed25519.pub"
}
