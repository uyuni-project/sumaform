terraform {
    required_version = ">= 0.8.0"
}

resource "libvirt_volume" "opensuse422" {
  name = "${var.name_prefix}opensuse422"
  source = "http://download.opensuse.org/repositories/home:/SilvioMoioli:/Terraform:/Images/images/opensuse422.x86_64.qcow2"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles11sp3" {
  name = "${var.name_prefix}sles11sp3"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles11sp3.x86_64.qcow2"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles11sp4" {
  name = "${var.name_prefix}sles11sp4"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles11sp4.x86_64.qcow2"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12" {
  name = "${var.name_prefix}sles12"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12.x86_64.qcow2"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12sp1" {
  name = "${var.name_prefix}sles12sp1"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp1.x86_64.qcow2"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12sp2" {
  name = "${var.name_prefix}sles12sp2"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp2.x86_64.qcow2"
  pool = "${var.pool}"
}

resource "libvirt_volume" "centos7" {
  name = "${var.name_prefix}centos7"
  source = "http://w3.nue.suse.com/~mbologna/sumaform-images/centos7.qcow2"
  pool = "${var.pool}"
}

output "configuration" {
  value = {
    network_name = "${var.network_name}"
    cc_username = "${var.cc_username}"
    cc_password = "${var.cc_password}"
    timezone = "${var.timezone}"
    package_mirror = "${var.package_mirror == "" ? "null" : var.package_mirror}"
    pool = "${var.pool}"
    bridge = "${var.bridge}"
    use_avahi = "${var.use_avahi ? "True" : "False"}"
    domain = "${var.domain}"
    name_prefix = "${var.name_prefix}"
  }
}
