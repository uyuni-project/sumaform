variable "images" {
  default = {
    "3.0-released" = "sles12sp1"
    "3.0-nightly" = "sles12sp1"
    "3.1-released" = "sles12sp3"
    "3.1-nightly" = "sles12sp3"
    "3.2-released" = "sles12sp3"
    "3.2-nightly" = "sles12sp3"
    "head" = "sles12sp3"
    "test" = "sles12sp3"
    "uyuni-released" = "opensuse423"
  }
}

module "suse_manager" {
  source = "../host"

  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  count = 1
  use_released_updates = "${var.use_released_updates}"
  use_unreleased_updates = "${var.use_unreleased_updates}"
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  ssh_key_path = "${var.ssh_key_path}"
  gpg_keys = "${var.gpg_keys}"
  connect_to_base_network = true
  connect_to_additional_network = false
  grains = <<EOF

product_version: ${var.product_version}
product_test_repository: ${var.product_test_repository}
cc_username: ${var.base_configuration["cc_username"]}
cc_password: ${var.base_configuration["cc_password"]}
channels: [${join(",", var.channels)}]
cloned_channels: ${var.cloned_channels}
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
publish_private_ssl_key: ${var.publish_private_ssl_key}
auto_accept: ${var.auto_accept}
monitored: ${var.monitored}
pts: ${var.pts}
pts_evil_minions: ${var.pts_evil_minions}
pts_locust: ${var.pts_locust}
pts_system_count: ${var.pts_system_count}
pts_system_prefix: ${var.pts_system_prefix}
apparmor: ${var.apparmor}
log_server: ${var.log_server}
from_email: ${var.from_email}
traceback_email: ${var.traceback_email}

EOF

  // Provider-specific variables
  image = "${var.image == "default" ? lookup(var.images, var.product_version) : var.image}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  mac = "${var.mac}"
}

output "configuration" {
  value {
    id = "${module.suse_manager.configuration["id"]}"
    hostname = "${module.suse_manager.configuration["hostname"]}"
    product_version = "${var.product_version}"
    username = "${var.server_username}"
    password = "${var.server_password}"
  }
}
