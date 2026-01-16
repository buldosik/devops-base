variable "vms" {
  description = "Config for vms"
  type = map(object({
    hostname   = string 
    private_ip = string
    memory     = optional(number, 2048)
    vcpu       = optional(number, 2)
  }))
}

# Optional
variable "ssh_key_path" {
  description = "Path to public SSH"
  type        = string
  default     = "/home/uadmin/.ssh/id_ed25519.pub"
}
