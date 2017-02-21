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
  grains = <<EOF

version: ${var.version}
package-mirror: ${var.base_configuration["package_mirror"]}
server: ${var.server_configuration["hostname"]}
role: client
for-development-only: ${element(list("False", "True"), var.for_development_only)}
for-testsuite-only: ${element(list("False", "True"), var.for_testsuite_only)}
${length(var.extra_repos) > 0 ? "extra_repos:" : ""}
${length(var.extra_repos) > 0 ? join("\n", formatlist("  %s: %s", keys(var.extra_repos), values(var.extra_repos))) : ""}

EOF
}

output "configuration" {
  value = "${module.client.configuration}"
}
