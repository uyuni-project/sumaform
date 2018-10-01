terraform {
    required_version = "~> 0.11.7"
}

resource "libvirt_volume" "centos7_volume" {
  name = "${var.name_prefix}centos7"
  source = "http://w3.nue.suse.com/~smoioli/sumaform-images/centos7_v3.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "centos7") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "opensuse423_volume" {
  name = "${var.name_prefix}opensuse423"
  source = "https://download.opensuse.org/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse423.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "opensuse423") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles15_volume" {
  name = "${var.name_prefix}sles15"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles15.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles15") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles11sp4_volume" {
  name = "${var.name_prefix}sles11sp4"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles11sp4.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles11sp4") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12_volume" {
  name = "${var.name_prefix}sles12"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12sp1_volume" {
  name = "${var.name_prefix}sles12sp1"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp1.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12sp1") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12sp2_volume" {
  name = "${var.name_prefix}sles12sp2"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp2.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12sp2") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12sp3_volume" {
  name = "${var.name_prefix}sles12sp3"
  source = "http://download.suse.de/install/SLE-12-SP3-JeOS-GM/SLES12-SP3-JeOS-for-kvm-and-xen.x86_64-GM.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12sp3") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles-es7_volume" {
  name = "${var.name_prefix}sles-es7"
  source = "http://w3.nue.suse.com/~smoioli/sumaform-images/sles-es7_v3.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles-es7") ? 1 : 0)}"
  pool = "${var.pool}"
}

# We fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "ubuntu-1804_volume" {
  name = "${var.name_prefix}ubuntu-1804"
  source = "https://cloud-images.ubuntu.com/releases/18.04/release/ubuntu-18.04-server-cloudimg-amd64.img"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "ubuntu-1804") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_network" "additional_network" {
  count = "${var.additional_network ? 1 : 0}"
  name = "${var.name_prefix}private"
  mode = "none"
  addresses = [ "192.168.5.0/24" ]
  dhcp { enabled = "false" }
}

output "configuration" {
  depends_on = [
    "libvirt_volume.centos7_volume",
    "libvirt_volume.opensuse423_volume",
    "libvirt_volume.sles15_volume",
    "libvirt_volume.sles11sp4_volume",
    "libvirt_volume.sles12_volume",
    "libvirt_volume.sles12sp1_volume",
    "libvirt_volume.sles12sp2_volume",
    "libvirt_volume.sles12sp3_volume",
    "libvirt_volume.sles-es7_volume",
    "libvirt_volume.ubuntu-1804_volume",
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
