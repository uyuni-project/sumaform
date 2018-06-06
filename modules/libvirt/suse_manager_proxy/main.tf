variable "images" {
  default = {
    "3.0-released" = "sles12sp1"
    "3.0-nightly" = "sles12sp1"
    "3.1-released" = "sles12sp3"
    "3.1-nightly" = "sles12sp3"
    "3.2-released" = "sles12sp3"
    "3.2-nightly" = "sles12sp3"
    "head" = "sles12sp3"
  }
}

module "suse_manager_proxy" {
  source = "../host"

  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  count = "${var.count}"
  use_released_updates = "${var.use_released_updates}"
  use_unreleased_updates = "${var.use_unreleased_updates}"
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  ssh_key_path = "${var.ssh_key_path}"
  gpg_keys = "${var.gpg_keys}"
  grains = <<EOF

version: ${var.version}
mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
role: suse_manager_proxy
auto_register: ${var.auto_register}
download_private_ssl_key: ${var.download_private_ssl_key}
auto_configure: ${var.auto_configure}
server_username: ${var.server_configuration["username"]}
server_password: ${var.server_configuration["password"]}
generate_bootstrap_script: ${var.generate_bootstrap_script}
publish_private_ssl_key: ${var.publish_private_ssl_key}
apparmor: ${var.apparmor}

EOF

  // Provider-specific variables
  image = "${var.image == "default" ? lookup(var.images, var.version) : var.image}"
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  mac = "${var.mac}"
}

output "configuration" {
  value {
    id = "${module.suse_manager_proxy.configuration["id"]}"
    hostname = "${module.suse_manager_proxy.configuration["hostname"]}"
    version = "${var.version}"
    username = "${var.server_configuration["username"]}"
    password = "${var.server_configuration["password"]}"
  }
}
