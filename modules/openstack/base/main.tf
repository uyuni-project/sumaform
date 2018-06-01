terraform {
    required_version = ">= 0.10.7"
}

resource "openstack_images_image_v2" "centos7_image" {
  name = "${var.name_prefix}centos7"
  image_source_url = "http://schnell.nue.suse.com/sumaform-images/openstack/centos7.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "centos7") ? 1 : 0)}"
  container_format = "bare"
  disk_format = "qcow2"
  properties {
    hw_rng_model = "virtio"
  }
}

resource "openstack_images_image_v2" "opensuse423_image" {
  name = "${var.name_prefix}opensuse423"
  image_source_url = "https://download.opensuse.org/repositories/systemsmanagement:/sumaform:/images:/openstack/images/opensuse423.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "opensuse423") ? 1 : 0)}"
  container_format = "bare"
  disk_format = "qcow2"
  properties {
    hw_rng_model = "virtio"
  }
}

resource "openstack_images_image_v2" "sles15_image" {
  name = "${var.name_prefix}sles15"
  image_source_url = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images:/OpenStack/images/sles15.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles15") ? 1 : 0)}"
  container_format = "bare"
  disk_format = "qcow2"
  properties {
    hw_rng_model = "virtio"
  }
}

resource "openstack_images_image_v2" "sles11sp4_image" {
  name = "${var.name_prefix}sles11sp4"
  image_source_url = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images:/OpenStack/images/sles11sp4.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles11sp4") ? 1 : 0)}"
  container_format = "bare"
  disk_format = "qcow2"
  properties {
    hw_rng_model = "virtio"
  }
}

resource "openstack_images_image_v2" "sles12_image" {
  name = "${var.name_prefix}sles12"
  image_source_url = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images:/OpenStack/images/sles12.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12") ? 1 : 0)}"
  container_format = "bare"
  disk_format = "qcow2"
  properties {
    hw_rng_model = "virtio"
  }
}

resource "openstack_images_image_v2" "sles12sp1_image" {
  name = "${var.name_prefix}sles12sp1"
  image_source_url = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images:/OpenStack/images/sles12sp1.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12sp1") ? 1 : 0)}"
  container_format = "bare"
  disk_format = "qcow2"
  properties {
    hw_rng_model = "virtio"
  }
}

resource "openstack_images_image_v2" "sles12sp2_image" {
  name = "${var.name_prefix}sles12sp2"
  image_source_url = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images:/OpenStack/images/sles12sp2.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12sp2") ? 1 : 0)}"
  container_format = "bare"
  disk_format = "qcow2"
  properties {
    hw_rng_model = "virtio"
  }
}

resource "openstack_images_image_v2" "sles12sp3_image" {
  name = "${var.name_prefix}sles12sp3"
  image_source_url = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images:/OpenStack/images/sles12sp3.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12sp3") ? 1 : 0)}"
  container_format = "bare"
  disk_format = "qcow2"
  properties {
    hw_rng_model = "virtio"
  }
}

resource "openstack_images_image_v2" "sles-es7_image" {
  name = "${var.name_prefix}sles-es7"
  image_source_url = "http://schnell.nue.suse.com/sumaform-images/openstack/sles-es7.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles-es7") ? 1 : 0)}"
  container_format = "bare"
  disk_format = "qcow2"
  properties {
    hw_rng_model = "virtio"
  }
}

resource "openstack_compute_secgroup_v2" "all_open_security_group" {
  name = "${var.name_prefix}all-open"
  description = "Sumaform security group with no restrictions"
  count = "${var.use_shared_resources ? 0 : 1}"

  rule {
    from_port   = 1
    to_port     = 65535
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 1
    to_port     = 65535
    ip_protocol = "udp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

output "configuration" {
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

    // Provider-specific variables
    centos7_image_id = "${join(",", openstack_images_image_v2.centos7_image.*.id)}"
    opensuse423_image_id = "${join(",", openstack_images_image_v2.opensuse423_image.*.id)}"
    sles15_image_id = "${join(",", openstack_images_image_v2.sles15_image.*.id)}"
    sles11sp4_image_id = "${join(",", openstack_images_image_v2.sles11sp4_image.*.id)}"
    sles12_image_id = "${join(",", openstack_images_image_v2.sles12_image.*.id)}"
    sles12sp1_image_id = "${join(",", openstack_images_image_v2.sles12sp1_image.*.id)}"
    sles12sp2_image_id = "${join(",", openstack_images_image_v2.sles12sp2_image.*.id)}"
    sles12sp3_image_id = "${join(",", openstack_images_image_v2.sles12sp3_image.*.id)}"
    sles-es7_image_id = "${join(",", openstack_images_image_v2.sles-es7_image.*.id)}"
  }
}
