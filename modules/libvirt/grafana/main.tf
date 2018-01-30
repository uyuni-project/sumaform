module "grafana" {
  source = "../host"

  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  ssh_key_path = "${var.ssh_key_path}"
  grains = <<EOF

mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
version: 3.0-nightly
role: grafana

EOF

  // Provider-specific variables
  image = "sles12sp2"
  memory = 4096
  vcpu = 1
  running = "${var.running}"
  mac = "${var.mac}"
}

output "configuration" {
  value = "${module.grafana.configuration}"
}
