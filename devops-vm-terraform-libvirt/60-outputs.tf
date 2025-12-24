output "vm_names" {
  value = [for _, m in module.vm : m.name]
}

output "public_ips" {
  value = {
    for k, m in module.vm :
    k => m.public_ips
  }
}

output "private_ips" {
  value = {
    for k, v in var.vms :
    k => v.private_ip
  }
}
