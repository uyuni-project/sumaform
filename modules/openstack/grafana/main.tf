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
product_version: "${var.product_version}"
role: grafana

EOF

  // Provider-specific variables
  image = "${var.image}"
  flavor = "${var.flavor}"
  floating_ips = "${var.floating_ips}"
}

output "configuration" {
  value = "${module.grafana.configuration}"
}
