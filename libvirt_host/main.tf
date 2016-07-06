variable "name" {}
variable "image" {}
variable "version" {
  default = "null"
}
variable "database" {
  default = "null"
}
variable "role" {}
variable "memory" {
  default = 512
}
variable "vcpu" {
  default = 1
}

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

//HACK: there's currently no better way to deploy a templated file
<<EOF

echo "hostname: ${var.name}
avahi-domain: ${var.avahi-domain}
package-mirror: ${var.package-mirror}
version: ${var.version}
database: ${var.database}
role: ${var.role}
server: ${var.server}
" >/etc/salt/grains

EOF
      ,
      "salt-call --force-color --file-root /root/salt --local state.sls terraform-support",
      "salt-call --force-color --file-root /root/salt --local state.highstate"
    ]
  }
}

output "hostname" {
    // HACK: hostname is taken from VM metadata in order to
    // establish dependencies with other modules
    value = "${coalesce(concat(var.name, ".", var.avahi-domain), libvirt_domain.domain.id)}"
}
