module "evil_minions" {
  source = "../host"
  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  image = "sles12sp2"
  count = "${var.count}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  mac = "${var.mac}"
  grains = <<EOF

version: 3.1-released
mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
role: evil_minions
evil_minion_count: ${var.evil_minion_count}
slowdown_factor: ${var.slowdown_factor}
minion_dump_yaml: ${base64encode(file(var.minion_dump_yml_file))}
install_from_git: ${var.install_from_git}

EOF
}

output "configuration" {
  value = "${module.evil_minions.configuration}"
}
