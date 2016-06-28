resource "libvirt_volume" "sles11sp3_volume" {
  name = "terraform_sles11sp3"
  source = "http://download.suse.de/ibs/home:/SilvioMoioli:/terraform:/sles11sp3/images/sles11sp3.x86_64.qcow2"
  pool = "${var.libvirt_pool}"
}
output "sles11sp3" {
  value = "${libvirt_volume.sles11sp3_volume.id}"
}

resource "libvirt_volume" "sles11sp4_volume" {
  name = "terraform_sles11sp4"
  source = "http://download.suse.de/ibs/home:/SilvioMoioli:/terraform:/sles11sp4/images/sles11sp4.x86_64.qcow2"
  pool = "${var.libvirt_pool}"
}
output "sles11sp4" {
  value = "${libvirt_volume.sles11sp4_volume.id}"
}

resource "libvirt_volume" "sles12_volume" {
  name = "terraform_sles12"
  source = "http://download.suse.de/ibs/home:/SilvioMoioli:/terraform:/sles12/images/sles12.x86_64.qcow2"
  pool = "${var.libvirt_pool}"
}
output "sles12" {
  value = "${libvirt_volume.sles12_volume.id}"
}

resource "libvirt_volume" "sles12sp1_volume" {
  name = "terraform_sles12sp1"
  source = "http://download.suse.de/ibs/home:/SilvioMoioli:/terraform:/sles12sp1/images/sles12sp1.x86_64.qcow2"
  pool = "${var.libvirt_pool}"
}
output "sles12sp1" {
  value = "${libvirt_volume.sles12sp1_volume.id}"
}
