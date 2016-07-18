resource "libvirt_volume" "sles11sp3" {
  name = "sumaform_sles11sp3"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles11sp3.x86_64.qcow2"
  pool = "${var.libvirt_pool}"
}
output "sles11sp3" {
  value = "${libvirt_volume.sles11sp3.id}"
}

resource "libvirt_volume" "sles11sp4" {
  name = "sumaform_sles11sp4"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles11sp4.x86_64.qcow2"
  pool = "${var.libvirt_pool}"
}
output "sles11sp4" {
  value = "${libvirt_volume.sles11sp4.id}"
}

resource "libvirt_volume" "sles12" {
  name = "sumaform_sles12"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12.x86_64.qcow2"
  pool = "${var.libvirt_pool}"
}
output "sles12" {
  value = "${libvirt_volume.sles12.id}"
}

resource "libvirt_volume" "sles12sp1" {
  name = "sumaform_sles12sp1"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp1.x86_64.qcow2"
  pool = "${var.libvirt_pool}"
}
output "sles12sp1" {
  value = "${libvirt_volume.sles12sp1.id}"
}
