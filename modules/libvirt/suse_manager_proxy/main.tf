module "suse_manager_proxy" {
  source = "../host"
  name = "${var.name}"
  image_id = "${var.image_id}"
  domain = "${var.domain}"
  count = "${var.count}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  pool = "${var.pool}"
  bridge = "${var.bridge}"
  mac = "${var.mac}"
  name_prefix = "${var.name_prefix}"
  grains = <<EOF

version: ${var.version}
package-mirror: ${var.package_mirror}
server: ${var.server}
role: suse-manager-proxy
for-development-only: True

EOF
}

output "hostname" {
  value = "${module.suse_manager_proxy.hostname}"
}
