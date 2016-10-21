resource "libvirt_volume" "volume" {
  name = "sumaform_sles11sp3"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles11sp3.x86_64.qcow2"
  pool = "${var.pool}"
}

output "id" {
  value = "${libvirt_volume.volume.id}"
}
