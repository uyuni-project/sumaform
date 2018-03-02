module "locust" {
  source = "../host"
  base_configuration = "${var.base_configuration}"
  name = "locust"
  ssh_key_path = "${var.ssh_key_path}"
  grains = <<EOF

mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
role: locust
locust_file: ${base64encode(file(var.locust_file))}
server_username: ${var.server_configuration["username"]}
server_password: ${var.server_configuration["password"]}
EOF

  // Provider-specific variables
  image = "opensuse423"
  flavor = "${var.flavor}"
  root_volume_size = "${var.root_volume_size}"
  floating_ips = "${var.floating_ips}"
}

output "configuration" {
  value {
    id = "${module.locust.configuration["id"]}"
    hostname = "${module.locust.configuration["hostname"]}"
  }
}
