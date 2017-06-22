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
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  grains = <<EOF

version: ${var.version}
mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
role: minion
for_development_only: ${var.for_development_only}
for_testsuite_only: ${var.for_testsuite_only}
use_unreleased_updates: ${var.use_unreleased_updates}
EOF
}

output "configuration" {
  value = "${module.minion.configuration}"
}
