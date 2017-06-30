variable "testsuite-branch" {
  default = {
    "3.0-released" = "manager30"
    "3.0-nightly" = "manager30"
    "3.1-released" = "manager31"
    "3.1-nightly" = "manager31"
    "head" = "master"
  }
}

module "controller" {
  source = "../host"
  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  image = "sles12sp1"
  memory = "${var.memory}"
  running = "${var.running}"
  mac = "${var.mac}"
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  grains = <<EOF

mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
client: ${var.client_configuration["hostname"]}
minion: ${var.minion_configuration["hostname"]}
centos_minion: ${var.centos_configuration["hostname"]}
ssh_minion: ${var.minionssh_configuration["hostname"]}
role: controller
branch: ${lookup(var.testsuite-branch, var.server_configuration["version"])}
EOF
}
