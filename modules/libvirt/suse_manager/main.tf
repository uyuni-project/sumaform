variable "images" {
  default = {
    "3.0-released" = "sles12sp1"
    "3.0-nightly" = "sles12sp1"
    "3.1-released" = "sles12sp2"
    "3.1-nightly" = "sles12sp2"
    "head" = "sles12sp3"
    "test" = "sles12sp2"
  }
}

module "suse_manager" {
  source = "../host"

  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  count = 1
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  ssh_key_path = "${var.ssh_key_path}"
  gpg_keys = "${var.gpg_keys}"
  grains = <<EOF

version: ${var.version}
cc_username: ${var.base_configuration["cc_username"]}
cc_password: ${var.base_configuration["cc_password"]}
database: ${var.database}
channels: [${join(",", var.channels)}]
mirror: ${var.base_configuration["mirror"]}
iss_master: ${var.iss_master}
iss_slave: ${var.iss_slave}
smt: ${var.smt}
role: suse_manager_server
for_development_only: ${var.for_development_only}
for_testsuite_only: ${var.for_testsuite_only}
unsafe_postgres: ${var.unsafe_postgres}
use_unreleased_updates: ${var.use_unreleased_updates}
auto_accept: ${var.auto_accept}
monitored: ${var.monitored}
log_server: ${var.log_server}
from_email: ${var.from_email}
traceback_email: ${var.traceback_email}

EOF

  // Provider-specific variables
  image = "${var.image == "default" ? lookup(var.images, var.version) : var.image}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  mac = "${var.mac}"
}

output "configuration" {
  value {
    id = "${module.suse_manager.configuration["id"]}"
    hostname = "${module.suse_manager.configuration["hostname"]}"
    version = "${var.version}"
  }
}
