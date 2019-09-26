terraform {
    required_version = "~> 0.11.7"
}

resource "libvirt_volume" "centos7_volume" {
  name = "${var.name_prefix}centos7"
  source = "${var.mirror != "" ? "http://${var.mirror}" : "https://github.com"}/moio/sumaform-images/releases/download/4.3.0/centos7.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "centos7") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "opensuse150_volume" {
  name = "${var.name_prefix}opensuse150"
  source = "${var.mirror != "" ? "http://${var.mirror}" : "https://download.opensuse.org"}/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse150.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "opensuse150") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "opensuse151_volume" {
  name = "${var.name_prefix}opensuse151"
  source = "${var.mirror != "" ? "http://${var.mirror}" : "https://download.opensuse.org"}/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse151.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "opensuse151") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles15_volume" {
  name = "${var.name_prefix}sles15"
  source = "http://${var.mirror != "" ? var.mirror : "download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles15.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles15") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles15sp1_volume" {
  name = "${var.name_prefix}sles15sp1"
  source = "http://${var.mirror != "" ? var.mirror : "download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles15sp1.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles15sp1") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles11sp4_volume" {
  name = "${var.name_prefix}sles11sp4"
  source = "http://${var.mirror != "" ? var.mirror : "download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles11sp4.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles11sp4") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12_volume" {
  name = "${var.name_prefix}sles12"
  source = "http://${var.mirror != "" ? var.mirror : "download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12sp1_volume" {
  name = "${var.name_prefix}sles12sp1"
  source = "http://${var.mirror != "" ? var.mirror : "download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp1.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12sp1") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12sp2_volume" {
  name = "${var.name_prefix}sles12sp2"
  source = "http://${var.mirror != "" ? var.mirror : "download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp2.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12sp2") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12sp3_volume" {
  name = "${var.name_prefix}sles12sp3"
  source = "http://${var.mirror != "" ? var.mirror : "download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp3.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12sp3") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12sp4_volume" {
  name = "${var.name_prefix}sles12sp4"
  source = "http://${var.mirror != "" ? var.mirror : "download.suse.de"}/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp4.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12sp4") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "ubuntu1804_volume" {
  name = "${var.name_prefix}ubuntu1804"
  source = "${var.mirror != "" ? "http://${var.mirror}" : "https://github.com"}/moio/sumaform-images/releases/download/4.4.0/ubuntu1804.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "ubuntu1804") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_network" "additional_network" {
  count = "${var.additional_network == "" ? 0 : 1}"
  name = "${var.name_prefix}private"
  mode = "none"
  addresses = [ "${var.additional_network}" ]
  dhcp { enabled = "false" }
  autostart = "true"
}

output "configuration" {
  depends_on = [
    "libvirt_volume.centos7_volume",
    "libvirt_volume.opensuse150_volume",
    "libvirt_volume.opensuse151_volume",
    "libvirt_volume.sles15_volume",
    "libvirt_volume.sles15sp1_volume",
    "libvirt_volume.sles11sp4_volume",
    "libvirt_volume.sles12_volume",
    "libvirt_volume.sles12sp1_volume",
    "libvirt_volume.sles12sp2_volume",
    "libvirt_volume.sles12sp3_volume",
    "libvirt_volume.sles12sp4_volume",
    "libvirt_volume.ubuntu1804_volume",
    "libvirt_network.additional_network"
  ]
  value = {
    cc_username = "${var.cc_username}"
    cc_password = "${var.cc_password}"
    timezone = "${var.timezone}"
    ssh_key_path = "${var.ssh_key_path}"
    mirror = "${var.mirror == "" ? "null" : var.mirror}"
    use_avahi = "${var.use_avahi}"
    domain = "${var.domain}"
    name_prefix = "${var.name_prefix}"
    use_shared_resources = "${var.use_shared_resources}"
    testsuite = "${var.testsuite}"
    additional_network = "${var.additional_network}"
    additional_network_id = "${join(",", libvirt_network.additional_network.*.id)}"

    // Provider-specific variables
    pool = "${var.pool}"
    network_name = "${var.bridge == "" ? var.network_name : ""}"
    bridge = "${var.bridge}"
  }
}
