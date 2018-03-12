terraform {
    required_version = ">= 0.10.7"
}

resource "openstack_images_image_v2" "images" {
  name = "${var.name_prefix}${element(var.images, count.index)}"
  image_source_url = "${var.image_locations["${element(var.images, count.index)}"]}"
  count = "${var.use_shared_resources ? 0 : length(var.images)}"
  container_format = "bare"
  disk_format = "qcow2"
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
    image_ids = "${join(",", openstack_images_image_v2.images.*.id)}"
  }
}
