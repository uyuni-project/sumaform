module "minion" {
  source = "../host"

  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  count = "${var.count}"
  use_released_updates = "${var.use_released_updates}"
  use_unreleased_updates = "${var.use_unreleased_updates}"
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  gpg_keys = "${var.gpg_keys}"
  ssh_key_path = "${var.ssh_key_path}"
  grains = <<EOF

product_version: ${var.product_version}
mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
role: minion
auto_connect_to_master: ${var.auto_connect_to_master}
apparmor: ${var.apparmor}

susemanager:
  activation_key: ${var.activation_key}

evil_minion_count: ${var.evil_minion_count}
evil_minion_slowdown_factor: ${var.evil_minion_slowdown_factor}

EOF

  // Provider-specific variables
  image = "${var.image}"
  flavor = "${var.flavor}"
  floating_ips = "${var.floating_ips}"
}

output "configuration" {
  value = "${module.minion.configuration}"
}
