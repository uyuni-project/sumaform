terraform {
    required_version = ">= 0.8.0"
}

resource "openstack_compute_flavor_v2" "sumaform-flavor" {
  name  = "xxl-sumaform"
  ram   = "8096"
  vcpus = "2"
  disk  = "200"
}


resource "openstack_images_image_v2" "sles12sp3" {
  name   = "sles12sp3_sumaform"
  image_source_url = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp3.x86_64.qcow2"
  container_format = "bare"
  disk_format = "qcow2"

}

resource "openstack_compute_instance_v2" "instance" {
  name = "${var.name}"
  image_name = "${var.image}"
  flavor_name = "xxl-sumaform"
  security_groups = ["default"]
  region = ""
  count = "${var.count}"

  network {
    access_network = true
    name = "fixed"
  }

  connection {
    user = "root"
    password = "linux"
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
