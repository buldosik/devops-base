output "name" {
  value = libvirt_domain.vm.name
}

output "public_ips" {
  value = libvirt_domain.vm.network_interface[0].addresses
}
