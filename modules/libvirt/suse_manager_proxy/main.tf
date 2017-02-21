variable "images" {
  default = {
    "2.1-stable" = "sles11sp3"
    "2.1-nightly" = "sles11sp3"
    "3-stable" = "sles12sp1"
    "3-nightly" = "sles12sp1"
    "head" = "sles12sp1"
  }
}

module "suse_manager_proxy" {
  source = "../host"
  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  image = "${lookup(var.images, var.version)}"
  count = "${var.count}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  mac = "${var.mac}"
  extra_repos = "${var.extra_repos}"
  grains = <<EOF

version: ${var.version}
package-mirror: ${var.base_configuration["package_mirror"]}
server: ${var.server_configuration["hostname"]}
role: suse-manager-proxy
for-development-only: ${element(list("False", "True"), var.for_development_only)}

EOF
}

output "configuration" {
  value = "${module.suse_manager_proxy.configuration}"
}
