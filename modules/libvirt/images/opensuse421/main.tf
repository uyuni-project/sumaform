resource "libvirt_volume" "volume" {
  name = "${var.name_prefix}opensuse421"
  source = "http://download.opensuse.org/repositories/home:/SilvioMoioli:/Terraform:/Images/images/opensuse421.x86_64.qcow2"
  pool = "${var.pool}"
}

output "id" {
  value = "${libvirt_volume.volume.id}"
}
