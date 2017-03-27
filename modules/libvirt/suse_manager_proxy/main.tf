variable "images" {
  default = {
    "2.1-stable" = "sles11sp3"
    "2.1-nightly" = "sles11sp3"
    "3-stable" = "sles12sp1"
    "3-nightly" = "sles12sp1"
    "3.1-stable" = "sles12sp2"
    "head" = "sles12sp2"
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
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  grains = <<EOF

version: ${var.version}
mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
role: suse_manager_proxy
for_development_only: ${var.for_development_only ? "True" : "False"}

EOF
}

output "configuration" {
  value = "${module.suse_manager_proxy.configuration}"
}
