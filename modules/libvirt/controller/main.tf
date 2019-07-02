variable "testsuite-branch" {
  default = {
    "3.0-released" = "Manager-3.0"
    "3.0-nightly" = "Manager-3.0"
    "3.1-released" = "Manager-3.1"
    "3.1-nightly" = "Manager-3.1"
    "3.2-released" = "Manager-3.2"
    "3.2-nightly" = "Manager-3.2"
    "4.0-released" = "Manager-4.0"
    "4.0-nightly" = "Manager-4.0"
    "head" = "master"
    "test" = "master"
    "uyuni-released" = "master"
  }
}

module "controller" {
  source = "../host"

  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  swap_file_size = "${var.swap_file_size}"
  ssh_key_path = "${var.ssh_key_path}"
  ipv6 = "${var.ipv6}"
  connect_to_base_network = true
  connect_to_additional_network = false
  grains = <<EOF

git_username: ${var.git_username}
git_password: ${var.git_password}
git_repo: ${var.git_repo}
mirror: ${var.base_configuration["mirror"]}
server: ${var.server_configuration["hostname"]}
proxy: ${var.proxy_configuration["hostname"]}
client: ${var.client_configuration["hostname"]}
minion: ${var.minion_configuration["hostname"]}
centos_minion: ${var.centos_configuration["hostname"]}
ubuntu_minion:  ${var.ubuntu_configuration["hostname"]}
ssh_minion: ${var.minionssh_configuration["hostname"]}
kvm_host: ${var.kvmhost_configuration["hostname"]}
pxeboot_mac: ${var.pxeboot_configuration["macaddr"]}
role: controller
branch: ${var.branch == "default" ? lookup(var.testsuite-branch, var.server_configuration["product_version"]) : var.branch}
git_profiles_repo: ${var.git_profiles_repo == "default" ? "https://github.com/uyuni-project/uyuni.git#:testsuite/features/profiles" : var.git_profiles_repo}
server_http_proxy: ${var.server_http_proxy}

EOF

  // Provider-specific variables
  image = "opensuse150"
  vcpu = "${var.vcpu}"
  memory = "${var.memory}"
  running = "${var.running}"
  mac = "${var.mac}"
}
