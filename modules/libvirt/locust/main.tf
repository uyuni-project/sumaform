module "locust" {
  source = "../host"
  base_configuration = "${var.base_configuration}"
  name = "locust"
  ssh_key_path = "${var.ssh_key_path}"
  grains = <<EOF

mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
role: locust
git_username: ${var.git_username}
git_password: ${var.git_password}
locust_file: ${base64encode(file(var.locust_file))}
EOF

  // Provider-specific variables
  image = "opensuse423"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
}
