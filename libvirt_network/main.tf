resource "libvirt_network" "network" {
  name = "terraform-network"
  mode = "nat"
  domain = "${var.domain}"
  addresses = ["${var.addresses}"]
}
