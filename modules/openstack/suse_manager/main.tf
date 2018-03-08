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
channels: [${join(",", var.channels)}]
mirror: ${var.base_configuration["mirror"]}
iss_master: ${var.iss_master}
iss_slave: ${var.iss_slave}
smt: ${var.smt}
role: suse_manager_server
server_username: ${var.server_username}
server_password: ${var.server_password}
disable_firewall: ${var.disable_firewall}
allow_postgres_connections: ${var.allow_postgres_connections}
unsafe_postgres: ${var.unsafe_postgres}
java_debugging: ${var.java_debugging}
skip_changelog_import: ${var.skip_changelog_import}
browser_side_less: ${var.browser_side_less}
create_first_user: ${var.create_first_user}
mgr_sync_autologin: ${var.mgr_sync_autologin}
create_sample_channel: ${var.create_sample_channel}
create_sample_activation_key: ${var.create_sample_activation_key}
create_sample_bootstrap_script: ${var.create_sample_bootstrap_script}
for_development_only: ${var.for_development_only}
testsuite: ${var.base_configuration["testsuite"]}
use_unreleased_updates: ${var.use_unreleased_updates}
auto_accept: ${var.auto_accept}
monitored: ${var.monitored}
log_server: ${var.log_server}
from_email: ${var.from_email}
traceback_email: ${var.traceback_email}

EOF

  // Provider-specific variables
  image = "${var.image == "default" ? lookup(var.images, var.version) : var.image}"
  flavor = "${var.flavor}"
  root_volume_size = "${var.root_volume_size}"
  floating_ips = "${var.floating_ips}"
}

output "configuration" {
  value {
    id = "${module.suse_manager.configuration["id"]}"
    hostname = "${module.suse_manager.configuration["hostname"]}"
    version = "${var.version}"
    username = "${var.server_username}"
    password = "${var.server_password}"
  }
}
