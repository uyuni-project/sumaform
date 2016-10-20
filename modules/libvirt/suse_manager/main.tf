variable "images" {
  default = {
    "2.1-stable" = "sles11sp3"
    "2.1-nightly" = "sles11sp3"
    "3-stable" = "sles12sp1"
    "3-nightly" = "sles12sp1"
    "head" = "sles12sp1"
  }
}

module "suse_manager" {
  source = "../host"
  name = "${var.name}"
  image = "${lookup(var.images, var.version)}"
  domain = "${var.domain}"
  count = 1
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  pool = "${var.pool}"
  bridge = "${var.bridge}"
  grains = <<EOF

version: ${var.version}
cc_username: ${var.cc_username}
cc_password: ${var.cc_password}
database: ${var.database}
package-mirror: ${var.package_mirror}
iss-master: ${var.iss_master}
iss-slave: ${var.iss_slave}
role: suse-manager-server
for-development-only: True

EOF
}

output "hostname" {
  value = "${module.suse_manager.hostname}"
}
