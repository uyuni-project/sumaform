variable "testsuite-branch" {
  default = {
    "3.0-released" = "Manager-3.0"
    "3.0-nightly" = "Manager-3.1"
    "3.1-released" = "Manager-3.1"
    "3.1-nightly" = "Manager-3.1"
    "head" = "Manager"
    "test" = "Manager"
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
  ssh_key_path = "${var.ssh_key_path}"
  grains = <<EOF

mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
client: ${var.client_configuration["hostname"]}
minion: ${var.minion_configuration["hostname"]}
centos_minion: ${var.centos_configuration["hostname"]}
ssh_minion: ${var.minionssh_configuration["hostname"]}
role: controller
branch: ${var.branch == "default" ? lookup(var.testsuite-branch, var.server_configuration["version"]) : var.branch}
EOF
}
