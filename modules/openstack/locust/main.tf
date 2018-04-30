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
locust_master_host: null
locust_slave_count: ${var.slave_count}
EOF

  // Provider-specific variables
  image = "opensuse423"
  flavor = "${var.flavor}"
  root_volume_size = "${var.root_volume_size}"
  floating_ips = "${var.floating_ips}"
}

module "locust-slave" {
  source = "../host"
  base_configuration = "${var.base_configuration}"
  name = "${var.name}-slave"
  count = "${var.slave_count}"
  ssh_key_path = "${var.ssh_key_path}"
  grains = <<EOF

mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
role: locust
locust_file: ${base64encode(file(var.locust_file))}
server_username: ${var.server_configuration["username"]}
server_password: ${var.server_configuration["password"]}
locust_master_host: ${module.locust.configuration["hostname"]}
EOF

  // Provider-specific variables
  image = "opensuse423"
  flavor = "${var.flavor}"
  root_volume_size = "${var.root_volume_size}"
}


output "configuration" {
  value {
    id = "${module.locust.configuration["id"]}"
    hostname = "${module.locust.configuration["hostname"]}"
  }
}
