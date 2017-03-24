terraform {
    required_version = ">= 0.8.0"
}

resource "openstack_compute_floatingip_v2" "floatip" {
  region = ""
  pool = "floating"
  count = "${var.count}"
}

resource "openstack_compute_instance_v2" "instance" {
  name = "${var.name}"
  image_name = "${var.image}"
  flavor_name = "${var.flavor}"
  security_groups = ["default"]
  region = ""
  count = "${var.count}"

  network {
    uuid = "8cce38fd-443f-4b87-8ea5-ad2dc184064f"
    # Terraform will use this network for provisioning
    floating_ip = "${element(openstack_compute_floatingip_v2.floatip.*.address, count.index)}"
    access_network = true
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
authorized-keys: null
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
