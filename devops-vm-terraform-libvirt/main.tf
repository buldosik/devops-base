terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# 1) Базовый образ Ubuntu (cloud image), скачивается в storage pool "default"
resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-24.04-base.qcow2"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  format = "qcow2"
}

# 2) Cloud-init диск (ISO), который лежит в pool "default",
# а контент (user-data.yml) лежит у тебя в репозитории на винде
resource "libvirt_cloudinit_disk" "ubuntu_ci" {
  name = "ubuntu-devops-cloudinit.iso"
  pool = "default"

  user_data = file("${path.module}/cloud-init/user-data.yml")
}

# 3) Виртуальная машина
resource "libvirt_domain" "ubuntu_vm" {
  name   = "devops-vm"
  memory = "2048"
  vcpu   = 2

  # Диск
  disk {
    volume_id = libvirt_volume.ubuntu_base.id
  }

  # Cloud-init ISO, сгенерированный ресурсом выше
  cloudinit = libvirt_cloudinit_disk.ubuntu_ci.id

  # Сеть — дефолтная libvirt (NAT), как у Vagrant’а
  network_interface {
    network_name = "default"
  }

  # Консоль для virsh console
  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  # Графика — VNC, можно подключаться vncviewer’ом
  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}
