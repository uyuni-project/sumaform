resource "libvirt_volume" "opensuse421" {
  name = "${var.name_prefix}opensuse421"
  source = "http://download.opensuse.org/repositories/home:/SilvioMoioli:/Terraform:/Images/images/opensuse421.x86_64.qcow2"
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

output "configuration" {
  // HACK: work around https://github.com/hashicorp/terraform/issues/9549
  value = "${
    map(
      "opensuse421", "${libvirt_volume.opensuse421.id}",
      "sles11sp3", "${libvirt_volume.sles11sp3.id}",
      "sles11sp4", "${libvirt_volume.sles11sp4.id}",
      "sles12", "${libvirt_volume.sles12.id}",
      "sles12sp1", "${libvirt_volume.sles12sp1.id}",
      "sles12sp2", "${libvirt_volume.sles12sp2.id}",
      "network_name", "${var.network_name}",

      "cc_username", "${var.cc_username}",
      "cc_password", "${var.cc_password}",
      "package_mirror", "${replace(var.package_mirror, "/^$/", "null")}",
      "pool", "${var.pool}",
      "bridge", "${var.bridge}",
      "use_avahi", "${element(list("False", "True"), var.use_avahi)}",
      "domain", "${var.domain}",
      "name_prefix", "${var.name_prefix}"
    )
  }"
}
