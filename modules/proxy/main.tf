variable "images" {
  default = {
    "4.0-released"   = "sles15sp1o"
    "4.0-nightly"    = "sles15sp1o"
    "4.1-released"   = "sles15sp2o"
    "4.1-nightly"    = "sles15sp2o"
    "4.2-released"   = "sles15sp3o"
    "4.2-nightly"    = "sles15sp3o"
    "4.3-released"   = "sles15sp4o"
    "4.3-nightly"    = "sles15sp4o"
    "4.3-beta"       = "sles15sp4o"
    "head"           = "sles15sp4o"
    "uyuni-master"   = "opensuse153o"
    "uyuni-released" = "opensuse153o"
    "uyuni-pr"       = "opensuse153o"
  }
}

module "proxy" {
  source = "../host"

  base_configuration            = var.base_configuration
  name                          = var.name
  quantity                      = var.quantity
  use_os_released_updates       = var.use_os_released_updates
  use_os_unreleased_updates     = var.use_os_unreleased_updates
  install_salt_bundle           = var.install_salt_bundle
  additional_repos              = var.additional_repos
  additional_repos_only         = var.additional_repos_only
  additional_packages           = var.additional_packages
  swap_file_size                = var.swap_file_size
  ssh_key_path                  = var.ssh_key_path
  gpg_keys                      = var.gpg_keys
  ipv6                          = var.ipv6
  connect_to_base_network       = true
  connect_to_additional_network = true
  roles                         = ["proxy"]
  disable_firewall              = var.disable_firewall
  grains = {
    product_version           = var.product_version
    mirror                    = var.base_configuration["mirror"]
    server                    = var.server_configuration["hostname"]
    minion                    = var.minion
    auto_connect_to_master    = var.auto_connect_to_master
    auto_register             = var.auto_register
    download_private_ssl_key  = var.download_private_ssl_key
    install_proxy_pattern     = var.install_proxy_pattern
    auto_configure            = var.auto_configure
    server_username           = var.server_configuration["username"]
    server_password           = var.server_configuration["password"]
    generate_bootstrap_script = var.generate_bootstrap_script
    publish_private_ssl_key   = var.publish_private_ssl_key
    repository_disk_size      = var.repository_disk_size
    proxy_registration_code   = var.proxy_registration_code
    accept_all_ssl_protocols  = var.accept_all_ssl_protocols
    proxy_containerized       = var.proxy_containerized
  }

  image                    = var.image == "default" || var.product_version == "head" ? var.images[var.product_version] : var.image
  provider_settings        = var.provider_settings
  additional_disk_size     = var.repository_disk_size
  volume_provider_settings = var.volume_provider_settings
}

output "configuration" {
  value = {
    id              = length(module.proxy.configuration["ids"]) > 0 ? module.proxy.configuration["ids"][0] : null
    hostname        = length(module.proxy.configuration["hostnames"]) > 0 ? module.proxy.configuration["hostnames"][0] : null
    product_version = var.product_version
    username        = var.server_configuration["username"]
    password        = var.server_configuration["password"]
  }
}
