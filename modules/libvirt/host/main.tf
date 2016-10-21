resource "libvirt_volume" "main_disk" {
  name = "terraform_${var.name}_${count.index}_disk"
  base_volume_id = "${var.image_id}"
  pool = "${var.pool}"
  count = "${var.count}"
}

resource "libvirt_domain" "domain" {
  name = "${var.name}_${count.index}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  count = "${var.count}"

  disk {
    volume_id = "${element(libvirt_volume.main_disk.*.id, count.index)}"
  }

  network_interface {
    wait_for_lease = true
    // HACK: evaluates to "terraform-network" if bridge is empty, "" otherwise
    network_name = "${element(list("terraform-network", ""), replace(replace(var.bridge, "/.+/", "1"), "/^$/", "0"))}"
    bridge = "${var.bridge}"
    mac = "${var.mac}"
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
${var.grains}

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
