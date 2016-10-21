resource "libvirt_volume" "volume" {
  name = "${var.name_prefix}sles11sp4"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles11sp4.x86_64.qcow2"
  pool = "${var.pool}"
}

output "id" {
  value = "${libvirt_volume.volume.id}"
}
