module "minion" {
  source = "../host"
  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  image = "${var.image}"
  count = "${var.count}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  mac = "${var.mac}"
  grains = <<EOF

package-mirror: ${var.base_configuration["package_mirror"]}
server: ${var.server_configuration["hostname"]}
role: minion
for-development-only: ${element(list("False", "True"), var.for_development_only)}
for-testsuite-only: ${element(list("False", "True"), var.for_testsuite_only)}

EOF
}

output "configuration" {
  value = "${module.minion.configuration}"
}
