terraform {
    required_version = ">= 0.10.7"
}

resource "libvirt_volume" "volumes" {
  name = "${var.name_prefix}${element(var.images, count.index)}"
  source = "${var.image_locations["${element(var.images, count.index)}"]}"
  count = "${var.use_shared_resources ? 0 : length(var.images)}"
  pool = "${var.pool}"
}

output "configuration" {
  depends_on = ["libvirt_volume.volumes"]
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

    // Provider-specific variables
    pool = "${var.pool}"
    network_name = "${var.bridge == "" ? var.network_name : ""}"
    bridge = "${var.bridge}"
  }
}
