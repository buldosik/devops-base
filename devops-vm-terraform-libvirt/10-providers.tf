terraform {

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    template = {
      source = "hashicorp/template"
    }
    local = {
      source = "hashicorp/local"
    }
  }

  cloud {
    organization = "buldosik-test"

    workspaces {
      name = "devops-vm-libvirt"
    }
  }
  
  #backend "remote" {
  #  organization = "buldosik-test"
  #
  #  workspaces {
  #    name = "devops-vm-libvirt"
  #  }
  #}
}


provider "libvirt" {
  uri = "qemu:///system"
}
