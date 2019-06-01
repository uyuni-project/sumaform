module "client" {
  source = "../host"

  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  count = "${var.count}"
  use_os_released_updates = "${var.use_os_released_updates}"
  use_os_unreleased_updates = "${var.use_os_unreleased_updates}"
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  gpg_keys = "${var.gpg_keys}"
  swap_file_size = "${var.swap_file_size}"
  ssh_key_path = "${var.ssh_key_path}"
  ipv6 = "${var.ipv6}"
  grains = <<EOF

product_version: ${var.product_version}
mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
role: client
auto_register: ${var.auto_register}

EOF

  // Provider-specific variables
  image = "${var.image}"
  flavor = "${var.flavor}"
  floating_ips = "${var.floating_ips}"
}

output "configuration" {
  value = "${module.client.configuration}"
}
