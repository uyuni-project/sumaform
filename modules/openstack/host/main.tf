terraform {
    required_version = ">= 0.10.7"
}

data "openstack_images_image_v2" "image" {
  name = "${var.base_configuration["use_shared_resources"] ? "" : var.base_configuration["name_prefix"]}${var.image}"
  most_recent = true
}

// Names are calculated as follows:
// ${var.base_configuration["name_prefix"]}${var.name}${var.count > 1 ? "-${count.index  + 1}" : ""}
// This means:
//   name_prefix + name (if count = 1)
//   name_prefix + name + "-" + index (if count > 1)

resource "openstack_compute_instance_v2" "instance" {
  name = "${var.base_configuration["name_prefix"]}${var.name}${var.count > 1 ? "-${count.index  + 1}" : ""}"
  security_groups = ["${var.base_configuration["use_shared_resources"] ? "" : var.base_configuration["name_prefix"]}all-open"]
  flavor_name = "${var.flavor}"
  image_id = "${data.openstack_images_image_v2.image.id}"
  count = "${var.count}"

  block_device {
    uuid = "${data.openstack_images_image_v2.image.id}"
    source_type = "image"
    destination_type = "local"
    boot_index = 0
    delete_on_termination = true
  }

  network {
    access_network = true
    name = "fixed"
  }

  user_data = <<EOF
#cloud-config
ssh_pwauth: 1
EOF

}

resource "openstack_blockstorage_volume_v2" "extra_volume" {
  count = "${signum(var.extra_volume_size) * var.count}"
  size = "${var.extra_volume_size}"
}

resource "openstack_compute_volume_attach_v2" "attached" {
  count = "${signum(var.extra_volume_size) * var.count}"
  instance_id = "${element(openstack_compute_instance_v2.instance.*.id, count.index)}"
  volume_id = "${element(openstack_blockstorage_volume_v2.extra_volume.*.id, count.index)}"
}

resource "openstack_networking_floatingip_v2" "floating_ip" {
  pool = "floating"
  # HACK: it should be possible to use 0 in case var.floating_ips has a value
  # this is not possible though, because 1) ?: is not short-circuiting
  # 2) ?: can't return a list 3) element() does not operate on empty lists
  # and 4) expressions like list.*.attribute will fail if list is empty
  count = "${var.count}"
}

resource "openstack_compute_floatingip_associate_v2" "module_floating_ip_association" {
  floating_ip = "${element(openstack_networking_floatingip_v2.floating_ip.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.instance.*.id, count.index)}"
  count = "${length(var.floating_ips) == 0 ? var.count : 0}"
}

resource "openstack_compute_floatingip_associate_v2" "external_floating_ip_association" {
  floating_ip = "${element(var.floating_ips, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.instance.*.id, count.index)}"
  count = "${length(var.floating_ips) > 0 ? var.count : 0}"
}

resource "null_resource" "host_salt_configuration" {
  count = "${var.count}"
  depends_on = [
    "openstack_networking_floatingip_v2.floating_ip",
    "openstack_compute_floatingip_associate_v2.module_floating_ip_association",
    "openstack_compute_floatingip_associate_v2.external_floating_ip_association",
  ]

  triggers {
    instance_id = "${element(openstack_compute_instance_v2.instance.*.id, count.index)}"
  }

  connection {
    host = "${element(concat(var.floating_ips, openstack_networking_floatingip_v2.floating_ip.*.address), count.index)}"
    user = "root"
    password = "linux"
  }

  provisioner "file" {
    source = "salt"
    destination = "/root"
  }

  provisioner "file" {
    content = <<EOF

hostname: ${var.base_configuration["name_prefix"]}${var.name}${var.count > 1 ? "-${count.index  + 1}" : ""}
domain: ${var.base_configuration["domain"]}
use_avahi: ${var.base_configuration["use_avahi"]}
timezone: ${var.base_configuration["timezone"]}
use_released_updates: ${var.use_released_updates}
use_unreleased_updates: ${var.use_unreleased_updates}
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
authorized_keys: [${trimspace(file(var.base_configuration["ssh_key_path"]))},${trimspace(file(var.ssh_key_path))}]
gpg_keys:  [${join(", ", formatlist("'%s'", var.gpg_keys))}]
reset_ids: true
${var.grains}

EOF

    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sh /root/salt/first_deployment_highstate.sh"
    ]
  }
}

output "configuration" {
  value {
    id = "${null_resource.host_salt_configuration.0.id}"
    hostname = "${var.base_configuration["name_prefix"]}${var.name}${var.count > 1 ? "-1" : ""}.${var.base_configuration["domain"]}"
    address = "${openstack_networking_floatingip_v2.floating_ip.0.address}"
  }
}
