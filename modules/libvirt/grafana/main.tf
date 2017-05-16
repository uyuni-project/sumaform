module "grafana" {
  source = "../host"
  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  image = "sles12sp2"
  memory = 4096
  vcpu = 1
  running = "${var.running}"
  mac = "${var.mac}"
  grains = <<EOF

mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
version: released
role: grafana

EOF
}

output "configuration" {
  value = "${module.grafana.configuration}"
}
