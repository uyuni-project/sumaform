variable "images" {
  default = {
    "2.1-stable" = "sles11sp3"
    "2.1-nightly" = "sles11sp3"
    "3-stable" = "sles12sp1"
    "3-nightly" = "sles12sp1"
    "head" = "sles12sp1"
  }
}

module "proxy" {
  source = "../host"
  name = "${var.name}"
  image = "${lookup(var.images, var.version)}"
  domain = "${var.domain}"
  count = "${var.count}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  pool = "${var.pool}"
  bridge = "${var.bridge}"
  mac = "${var.mac}"
  grains = <<EOF

version: ${var.version}
package-mirror: ${var.package_mirror}
server: ${var.server}
role: suse-manager-proxy
for-development-only: True

EOF
}

output "hostname" {
  value = "${module.proxy.hostname}"
}
