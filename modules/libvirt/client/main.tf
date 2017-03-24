module "client" {
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
role: client
for-development-only: ${var.for_development_only ? "True" : "False"}
for-testsuite-only: ${var.for_testsuite_only ? "True" : "False"}

EOF
}

output "configuration" {
  value = "${module.client.configuration}"
}
