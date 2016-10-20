module "client" {
  source = "../host"
  name = "${var.name}"
  image = "${var.image}"
  domain = "${var.domain}"
  count = "${var.count}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  pool = "${var.pool}"
  bridge = "${var.bridge}"
  mac = "${var.mac}"
  grains = <<EOF

package-mirror: ${var.package_mirror}
server: ${var.server}
role: client
for-development-only: True

EOF
}

output "hostname" {
  value = "${module.client.hostname}"
}
