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
image: sles12sp2
mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
role: evil_minions
minion_count: ${var.minion_count}
minion_pool: ${var.minion_pool}
minion_dump_yml_file: ${var.minion_dump_yml_file}
slowdown_factor: ${var.slowdown_factor}

EOF
}

output "configuration" {
  value = "${module.evil_minions.configuration}"
}
