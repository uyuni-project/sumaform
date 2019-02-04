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
  connect_to_base_network = true
  connect_to_additional_network = true
  grains = <<EOF

product_version: ${var.product_version}
mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
role: minion
auto_connect_to_master: ${var.auto_connect_to_master}
apparmor: ${var.apparmor}

susemanager:
  activation_key: ${var.activation_key}

EOF

  // Provider-specific variables
  image = "${var.image}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  mac = "${var.mac}"
}

output "configuration" {
  value = "${module.minion.configuration}"
}
