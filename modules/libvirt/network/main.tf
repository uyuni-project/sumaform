resource "libvirt_network" "network" {
  name = "${var.name_prefix}nat_network"
  mode = "nat"
  domain = "${var.domain}"
  addresses = ["${var.addresses}"]
}
