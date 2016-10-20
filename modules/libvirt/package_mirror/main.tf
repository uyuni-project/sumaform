resource "libvirt_volume" "main_disk" {
  name = "terraform_package_mirror_main_disk"
  base_volume_name = "sumaform_opensuse421"
  pool = "${var.main_pool}"
}

resource "libvirt_volume" "data_disk" {
  name = "terraform_package_mirror_data_disk"
  size = 1099511627776 # 1 TiB
  pool = "${var.data_pool}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "libvirt_domain" "domain" {
  name = "package-mirror"
  memory = 512
  vcpu = 1
  running = "${var.running}"

  disk {
    volume_id = "${libvirt_volume.main_disk.id}"
  }
  disk {
    volume_id = "${libvirt_volume.data_disk.id}"
  }

  network_interface {
    wait_for_lease = true
    // HACK: evaluates to "terraform-network" if bridge is empty, "" otherwise
    network_name = "${element(list("terraform-network", ""), replace(replace(var.bridge, "/.+/", "1"), "/^$/", "0"))}"
    bridge = "${var.bridge}"
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

hostname: package-mirror
domain: ${var.domain}
use-avahi: True
role: package-mirror
cc_username: ${var.cc_username}
cc_password: ${var.cc_password}
data_disk_device: vdb

EOF

    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "salt-call --local state.sls terraform-resource",
      "salt-call --local state.highstate"
    ]
  }
}

output "hostname" {
    // HACK: this output artificially depends on the domain id
    // any resource using this output will have to wait until domain is fully up
    value = "${coalesce("package-mirror.${var.domain}", libvirt_domain.domain.id)}"
}
