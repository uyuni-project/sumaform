variable "images" {
  default = {
    "2.1-stable" = "sles11sp3"
    "2.1-nightly" = "sles11sp3"
    "3-stable" = "sles12sp1"
    "3-nightly" = "sles12sp1"
    "head" = "sles12sp1"
  }
}

module "suse_manager" {
  source = "../host"
  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  image = "${replace(var.image, "default", lookup(var.images, var.version))}"
  count = 1
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  mac = "${var.mac}"
  grains = <<EOF

version: ${var.version}
cc_username: ${var.base_configuration["cc_username"]}
cc_password: ${var.base_configuration["cc_password"]}
database: ${var.database}
package-mirror: ${var.base_configuration["package_mirror"]}
iss-master: ${var.iss_master}
iss-slave: ${var.iss_slave}
role: suse-manager-server
for-development-only: ${element(list("False", "True"), var.for_development_only)}
for-testsuite-only: ${element(list("False", "True"), var.for_testsuite_only)}

EOF
}

output "configuration" {
  value = "${module.suse_manager.configuration}"
}
