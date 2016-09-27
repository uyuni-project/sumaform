resource "openstack_compute_floatingip_v2" "floatip" {
  region = ""
  pool = "floating"
  count = "${var.count}"
}

resource "openstack_compute_instance_v2" "instance" {
  name = "${var.name}"
  image_name = "${var.image}"
  flavor_name = "m1.xlarge"
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

hostname: ${var.name}${element(list("", "-${count.index  + 1}"), signum(var.count - 1))}
domain: ${var.domain}
use-avahi: True
package-mirror: ${var.package-mirror}
version: ${var.version}
database: ${var.database}
role: ${var.role}
server: ${var.server}
iss-master: ${var.iss-master}
iss-slave: ${var.iss-slave}
for-development-only: True

EOF

    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "salt-call --force-color --local state.sls terraform-resource",
      "salt-call --force-color --local state.highstate"
    ]
  }
}

output "hostname" {
  // HACK: this output artificially depends on the instance id
  // any resource using this output will have to wait until instance is fully up
  value = "${coalesce("${var.name}.${var.domain}", openstack_compute_instance_v2.instance.id)}"
}
