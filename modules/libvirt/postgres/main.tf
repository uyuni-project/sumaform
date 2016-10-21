module "postgres" {
  source = "../host"
  name = "${var.name}"
  image_id = "${var.image_id}"
  domain = "${var.domain}"
  count = 1
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  pool = "${var.pool}"
  bridge = "${var.bridge}"
  mac = "${var.mac}"
  name_prefix = "${var.name_prefix}"
  grains = <<EOF

package-mirror: ${var.package_mirror}
role: postgres
for-development-only: True

EOF
}

output "hostname" {
  value = "${module.postgres.hostname}"
}
