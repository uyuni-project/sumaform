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

echo "hostname: ${var.name}
domain: ${var.domain}
package-mirror: ${var.package-mirror}
version: ${var.version}
database: ${var.database}
role: ${var.role}
server: ${var.server}
iss-master: ${var.iss-master}
iss-slave: ${var.iss-slave}
for-development-only: True
" >/etc/salt/grains

EOF
      ,
      "salt-call --force-color --local state.sls terraform-resource",
      "salt-call --force-color --local state.highstate"
    ]
  }
}

output "hostname" {
    // HACK: hostname is taken from VM metadata in order to
    // establish dependencies with other modules
    value = "${coalesce(concat(var.name, ".", var.domain), libvirt_domain.domain.id)}"
}
