module "minionssh" {
  source = "../host"

  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  quantity = "${var.quantity}"
  use_os_released_updates = "${var.use_os_released_updates}"
  use_os_unreleased_updates = "${var.use_os_unreleased_updates}"
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  gpg_keys = "${var.gpg_keys}"
  swap_file_size = "${var.swap_file_size}"
  ssh_key_path = "${var.ssh_key_path}"
  ipv6 = "${var.ipv6}"
  connect_to_base_network = true
  connect_to_additional_network = true
  roles = ["minionssh"]
  grains = <<EOF

product_version: ${var.product_version}
mirror: ${var.base_configuration["mirror"]}

EOF

  // Provider-specific variables
  image = "${var.image}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  mac = "${var.mac}"
  cpu_model = "${var.cpu_model}"
  xslt = "${var.xslt}"
}

output "configuration" {
  value = "${module.minionssh.configuration}"
}
