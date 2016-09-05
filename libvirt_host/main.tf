resource "libvirt_volume" "main_disk" {
  name = "terraform_${var.name}_disk"
  base_volume_id = "${var.image}"
  pool = "${var.libvirt_pool}"
}

resource "libvirt_domain" "domain" {
  name = "${var.name}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"

  disk {
    volume_id = "${libvirt_volume.main_disk.id}"
  }

  network_interface {
    wait_for_lease = true
    network_name = "vagrant-libvirt"
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

hostname: ${var.name}
domain: ${var.domain}
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
    // HACK: this output artificially depends on the domain id
    // any resource using this output will have to wait until domain is fully up
    value = "${coalesce("${var.name}.${var.domain}", libvirt_domain.domain.id)}"
}
