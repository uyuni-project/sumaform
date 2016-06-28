resource "libvirt_volume" "terraform_sles11sp3" {
  name = "sles11sp3"
  source = "http://download.suse.de/ibs/home:/SilvioMoioli:/terraform:/sles11sp3/images/sles11sp3.x86_64.qcow2"
  pool = "default"
}

resource "libvirt_volume" "suma21pg_disk" {
  name = "suma21pg_disk"
  base_volume_id = "${libvirt_volume.terraform_sles11sp3.id}"
  pool = "default"
}

resource "template_file" "grains" {
  template = "${file("grains")}"

  vars {
    hostname = "suma21pg"
    avahi-domain = "${var.avahi-domain}"
    package-mirror = "${var.package-mirror}"
    version = "2.1-nightly"
    database = "postgres"
    role = "suse-manager-server"
  }
}

resource "libvirt_domain" "suma21pg" {
  name = "suma21pg"
  memory = 1024
  vcpu = 2
  disk {
    volume_id = "${libvirt_volume.suma21pg_disk.id}"
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
    value = "${libvirt_domain.suma21pg.network_interface.0.address.0.address}"
}
