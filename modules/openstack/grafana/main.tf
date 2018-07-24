module "grafana" {
  source = "../host"

  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  count = "${var.count}"
  ssh_key_path = "${var.ssh_key_path}"
  grains = <<EOF

mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
locust: ${var.locust_configuration["hostname"]}
product_version: 3.0-nightly
role: grafana

EOF

  // Provider-specific variables
  image = "sles12sp2"
  flavor = "m1.medium"
  floating_ips = "${var.floating_ips}"
}

output "configuration" {
  value = "${module.grafana.configuration}"
}
