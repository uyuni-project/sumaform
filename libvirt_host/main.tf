variable "name" {}
variable "image" {}
variable "version" {}
variable "database" {}
variable "role" {}
variable "memory" {}
variable "vcpu" {}

resource "libvirt_volume" "main_disk" {
  name = "terraform_${var.name}_disk"
  base_volume_id = "${var.image}"
  pool = "${var.libvirt_pool}"
}

resource "template_file" "grains" {
  template = "${file("${path.module}/grains")}"

  vars {
    hostname = "${var.name}"
    avahi-domain = "${var.avahi-domain}"
    package-mirror = "${var.package-mirror}"
    version = "${var.version}"
    database = "${var.database}"
    role = "${var.role}"
  }
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
    network = "vagrant-libvirt"
  }

  connection {
    user = "root"
    password = "vagrant"
  }

  provisioner "file" {
    source = "salt"
    destination = "/root"
  }

  provisioner "remote-exec" {
    inline = [
      "echo \"${template_file.grains.rendered}\" >> /etc/salt/grains",
      "salt-call --force-color --file-root /root/salt --local state.sls terraform-support",
      "salt-call --force-color --file-root /root/salt --local state.highstate"
    ]
  }
}

output "address" {
    value = "${libvirt_domain.domain.network_interface.0.address.0.address}"
}
