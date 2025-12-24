# cloud-init user-data
data "template_file" "cloud_init" {
  template = file(var.cloud_init_template)
  vars = {
    hostname   = var.hostname
    ssh_key    = var.ssh_key
    private_ip = var.private_ip
  }
}

resource "libvirt_cloudinit_disk" "ci" {
  name      = "${var.hostname}-ci.iso"
  pool      = var.pool
  user_data = data.template_file.cloud_init.rendered
}

resource "libvirt_volume" "os" {
  name           = "${var.hostname}-os.qcow2"
  pool           = var.pool
  base_volume_id = var.base_volume_id
  size           = 20 * 1024 * 1024 * 1024
}

resource "libvirt_domain" "vm" {
  name     = var.hostname
  memory   = var.memory
  vcpu     = var.vcpu
  cloudinit = libvirt_cloudinit_disk.ci.id

  network_interface {
    network_name   = var.public_network_name
    wait_for_lease = true
  }

  network_interface {
    network_id = var.private_network_id
  }

  disk {
    volume_id = libvirt_volume.os.id
  }

  graphics {
    type        = "spice"
    listen_type = "none"
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}
