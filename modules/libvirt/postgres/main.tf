module "postgres" {
  source = "../host"
  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  image = "sles12sp1"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  mac = "${var.mac}"
  grains = <<EOF

package-mirror: ${var.base_configuration["package_mirror"]}
role: postgres
for-development-only: True
${length(var.extra_repos) > 0 ? "extra_repos:" : ""}
${length(var.extra_repos) > 0 ? join("\n", formatlist("  %s: %s", keys(var.extra_repos), values(var.extra_repos))) : ""}

EOF
}

output "configuration" {
  value = "${module.postgres.configuration}"
}
