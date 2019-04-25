module "virthost" {
  source = "../host"

  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  gpg_keys = "${var.gpg_keys}"
  ssh_key_path = "${var.ssh_key_path}"
  connect_to_base_network = true
  connect_to_additional_network = true
  grains = <<EOF

mirror: ${var.base_configuration["mirror"]}
hvm_disk_image: "${var.hvm_disk_image}"
role: virthost
EOF

  // Provider-specific variables
  image = "${var.image}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  mac = "${var.mac}"
  cpu_model = "host-model"
}

output "configuration" {
  value = "${module.virthost.configuration}"
}
