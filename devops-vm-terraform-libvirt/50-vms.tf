module "vm" {
  source = "./modules/vm"

  for_each = var.vms

  hostname   = each.value.hostname
  memory     = each.value.memory
  vcpu       = each.value.vcpu
  private_ip = each.value.private_ip

  ssh_key             = file(var.ssh_key_path)
  base_volume_id      = libvirt_volume.ubuntu_base.id
  pool                = "default"
  private_network_id  = libvirt_network.private.id
  public_network_name = "default"

  cloud_init_template = "${path.module}/cloud-init.yaml"
}
