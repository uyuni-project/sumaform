module "minionswarm" {
  source = "../host"

  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  count = "${var.count}"
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  swap_file_size = "${var.swap_file_size}"
  ssh_key_path = "${var.ssh_key_path}"
  grains = <<EOF

product_version: 3.2-released
mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
role: minionswarm
minion_count: ${var.minion_count}
start_delay: ${var.start_delay}

EOF

  // Provider-specific variables
  image = "sles12sp1"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  mac = "${var.mac}"
}

output "configuration" {
  value = "${module.minionswarm.configuration}"
}
