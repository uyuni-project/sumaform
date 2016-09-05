
resource "libvirt_volume" "main_disk" {
  name = "terraform_package_mirror_main_disk"
  base_volume_id = "${var.image}"
  pool = "${var.libvirt_main_pool}"
}

resource "libvirt_volume" "data_disk" {
  name = "terraform_package_mirror_data_disk"
  size = 1099511627776 # 1 TiB
  pool = "${var.libvirt_data_pool}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "libvirt_domain" "domain" {
  name = "package-mirror"
  memory = 512
  vcpu = 1

  disk {
    volume_id = "${libvirt_volume.main_disk.id}"
  }
  disk {
    volume_id = "${libvirt_volume.data_disk.id}"
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

  provisioner "remote-exec" {
    inline = [

//HACK: there's currently no better way to deploy a templated file
<<EOF

echo "hostname: package-mirror
domain: ${var.domain}
role: package-mirror
" >/etc/salt/grains

EOF
      ,
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
