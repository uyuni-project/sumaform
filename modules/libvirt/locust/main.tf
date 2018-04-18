module "locust" {
  source = "../host"
  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
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
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  mac = "${var.mac}"
}

output "configuration" {
  value {
    id = "${module.locust.configuration["id"]}"
    hostname = "${module.locust.configuration["hostname"]}"
  }
}
