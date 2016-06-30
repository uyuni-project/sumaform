variable "name" {}
variable "image" {}
variable "version" {
  default = "null"
}
variable "database" {
  default = "null"
}
variable "role" {}

resource "openstack_compute_floatingip_v2" "floatip_1" {
  region = ""
  pool = "floating"
}

resource "openstack_compute_instance_v2" "suma21pg" {
  name = "${var.name}"
  image_name = "${var.image}"
  flavor_name = "m1.xlarge"
  security_groups = ["default"]
  region = ""
  network {
    uuid = "8cce38fd-443f-4b87-8ea5-ad2dc184064f"
    # Terraform will use this network for provisioning
    floating_ip = "${openstack_compute_floatingip_v2.floatip_1.address}"
    access_network = true
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
version: ${var.version}
database: ${var.database}
role: ${var.role}
" >/etc/salt/grains

EOF
      ,
      "salt-call --force-color --file-root /root/salt --local state.sls terraform-support",
      "salt-call --force-color --file-root /root/salt --local state.highstate"
    ]
  }
}

output "address" {
  value = "${openstack_compute_floatingip_v2.floatip_1.address}"
}
