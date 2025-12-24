resource "libvirt_network" "private" {
  name      = "devops-private"
  mode      = "nat"
  addresses = ["192.168.200.0/24"]
  autostart = true
}
