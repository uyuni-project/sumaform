module "evil_minions" {
  source = "../host"
  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  image = "${var.image}"
  count = "${var.count}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  mac = "${var.mac}"
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  grains = <<EOF

version: 3.1-released
mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
role: evil_minions
minion_count: ${var.minion_count}
start_delay: ${var.start_delay}

EOF
}

output "configuration" {
  value = "${module.evil_minions.configuration}"
}
