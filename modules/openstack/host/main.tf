terraform {
    required_version = ">= 0.8.0"
}

resource "openstack_blockstorage_volume_v2" "volume" {
  size = 50
  image_id = "${openstack_images_image_v2.sles12sp3.id}"
}

resource "openstack_images_image_v2" "sles12sp3" {
  name   = "sles12sp3_sumaform"
  image_source_url = "https://download.opensuse.org/repositories/systemsmanagement:/sumaform:/images:/openstack/images/opensuse422.x86_64-0.1.0-Build4.1.qcow2"
  container_format = "bare"
  disk_format = "qcow2"

}

resource "openstack_compute_instance_v2" "instance" {
  name = "${var.name}"
  security_groups = ["default"]
  region = ""
  flavor_name = "m1.xlarge"
  count = "${var.count}"

  network {
    access_network = true
    name = "fixed"
  }

  connection {
    user = "root"
    password = "linux"
  }

  block_device {
    uuid                  = "${openstack_blockstorage_volume_v2.volume.id}"
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
}


  provisioner "file" {
    source = "salt"
    destination = "/srv"
  }

  provisioner "file" {
    content = <<EOF

hostname: ${var.name}${var.count > 1 ? "-${count.index + 1}" : ""}
domain: ${var.domain}
use_avahi: True
mirror: null
version: ${var.version}
database: ${var.database}
role: ${var.role}
cc_username: ${var.cc_username}
cc_password: ${var.cc_password}
server: ${var.server_configuration["hostname"]}
iss_master: ${var.iss_master}
iss_slave: ${var.iss_slave}
for_development_only: True
for_testsuite_only: False
timezone: ${var.timezone}
authorized_keys: null
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]

EOF

    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "salt-call --force-color --local --output=quiet state.sls default,terraform-resource",
      "salt-call --force-color --local state.highstate"
    ]
  }
}

output "configuration" {
  value {
    id = "${openstack_compute_instance_v2.instance.id}"
    hostname = "${var.name}.${var.domain}"
  }
}

resource "openstack_networking_floatingip_v2" "fip_1" {
  region = ""
  pool = "floating"
  count = "${var.count}"
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = "${openstack_networking_floatingip_v2.fip_1.address}"
  instance_id = "${openstack_compute_instance_v2.instance.id}"
}
