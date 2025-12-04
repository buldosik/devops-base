terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}


provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-24.04-base.qcow2"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  format = "qcow2"
}

locals {
  vms = {
    back = {
      hostname   = "devops-back"
      memory     = 2048
      vcpu       = 2
      private_ip = "192.168.200.11"
    }
    db = {
      hostname   = "devops-db"
      memory     = 2048
      vcpu       = 2
      private_ip = "192.168.200.12"
    }
    dev = {
      hostname   = "devops-dev"
      memory     = 2048
      vcpu       = 2
      private_ip = "192.168.200.13"
    }
  }
}


resource "libvirt_volume" "os" {
  for_each = local.vms

  name           = "${each.value.hostname}-os.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = 20 * 1024 * 1024 * 1024  # 20GB
}

###################################
#####       CLOUD INIT        #####
###################################

data "template_file" "cloud_init" {
  for_each = local.vms

  template = file("${path.module}/cloud-init.yaml")
  vars = {
    hostname   = each.value.hostname
    ssh_key  = file("/home/uadmin/.ssh/id_ed25519.pub")
    private_ip = each.value.private_ip
  }
}


resource "libvirt_cloudinit_disk" "ci" {
  for_each = local.vms

  name      = "${each.value.hostname}-ci.iso"
  pool      = "default"
  user_data = data.template_file.cloud_init[each.key].rendered
}

###################################
#####         NETWORK         #####
###################################

#resource "libvirt_network" "public" {
#  name      = "devops-public"
#  mode      = "nat"
#  addresses = ["192.168.122.0/24"]
#}

resource "libvirt_network" "private" {
  name      = "devops-private"
  mode      = "nat"
  addresses = ["192.168.200.0/24"]
  autostart = true
}


##################################
#####           VM           #####
##################################
resource "libvirt_domain" "vm" {
  for_each = local.vms

  name   = each.value.hostname
  memory = each.value.memory
  vcpu   = each.value.vcpu
  cloudinit = libvirt_cloudinit_disk.ci[each.key].id

  network_interface {
    network_name   = "default"
    #wait_for_lease = true
  }

  network_interface {
    network_id = libvirt_network.private.id
  }



  disk {
    volume_id = libvirt_volume.os[each.key].id
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

output "vm_names" {
  value = [for _, v in libvirt_domain.vm : v.name]
}

output "public_ips" {
  value = {
    for k, v in libvirt_domain.vm :
    k => v.network_interface[0].addresses
  }
}

output "private_ips" {
  value = {
    for k, v in local.vms :
    k => v.private_ip
  }
}

resource "local_file" "ansible_inventory" {
  content = <<-EOT
  [back]
  ${libvirt_domain.vm["back"].network_interface[0].addresses[0]} ansible_user=devops

  [db]
  ${libvirt_domain.vm["db"].network_interface[0].addresses[0]} ansible_user=devops

  [dev]
  ${libvirt_domain.vm["dev"].network_interface[0].addresses[0]} ansible_user=devops
  EOT

  filename = "${path.module}/../ansible/inventory.ini"
}
