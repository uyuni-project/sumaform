variable "testsuite-branch" {
  default = {
    "3.0-released" = "Manager-3.0"
    "3.0-nightly" = "Manager-3.0"
    "3.1-released" = "Manager-3.1"
    "3.1-nightly" = "Manager-3.1"
    "3.2-released" = "Manager-3.2"
    "3.2-nightly" = "Manager-3.2"
    "head" = "Manager"
    "test" = "Manager"
  }
}

module "controller" {
  source = "../host"

  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  ssh_key_path = "${var.ssh_key_path}"
  grains = <<EOF

git_username: ${var.git_username}
git_password: ${var.git_password}
mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
proxy: ${var.proxy_configuration["hostname"]}
client: ${var.client_configuration["hostname"]}
minion: ${var.minion_configuration["hostname"]}
centos_minion: ${var.centos_configuration["hostname"]}
ssh_minion: ${var.minionssh_configuration["hostname"]}
role: controller
branch: ${var.branch == "default" ? lookup(var.testsuite-branch, var.server_configuration["product_version"]) : var.branch}

EOF

  // Provider-specific variables
  image = "opensuse423"
  memory = "${var.memory}"
  running = "${var.running}"
  mac = "${var.mac}"
  interfaces = [
    {
      wait_for_lease = true
      network_name = "${var.base_configuration["network_name"]}"
      bridge = "${var.base_configuration["bridge"]}"
      mac = "${var.mac}"
    }
  ]
}
