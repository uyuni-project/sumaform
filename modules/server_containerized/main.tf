variable "images" {
  default = {
    "head"           = "sles15sp4o"
    "uyuni-master"   = "opensuse154o"
    "uyuni-released" = "opensuse154o"
    "uyuni-pr"       = "opensuse154o"
  }
}

module "server_containerized" {
  source = "../host"

  base_configuration            = var.base_configuration
  name                          = var.name
  roles                         = ["server_containerized"]
  use_os_released_updates       = var.use_os_released_updates
  install_salt_bundle           = var.install_salt_bundle
  additional_repos              = var.additional_repos
  additional_repos_only         = var.additional_repos_only
  additional_certs              = var.additional_certs
  additional_packages           = var.additional_packages
  quantity                      = var.quantity
  swap_file_size                = var.swap_file_size
  ssh_key_path                  = var.ssh_key_path
  gpg_keys                      = var.gpg_keys
  ipv6                          = var.ipv6
  connect_to_base_network       = true
  connect_to_additional_network = false
  image                    = var.image == "default" || var.product_version == "head" ? var.images[var.product_version] : var.image
  provision                     = var.provision
  provider_settings             = var.provider_settings
  additional_disk_size          = var.additional_disk_size
  volume_provider_settings      = var.volume_provider_settings

  grains = {
    product_version        = var.product_version
    container_runtime      = var.runtime
    container_repository   = var.container_repository
    helm_chart_url         = var.helm_chart_url
    cc_username            = var.base_configuration["cc_username"]
    cc_password            = var.base_configuration["cc_password"]
    mirror                 = var.base_configuration["mirror"]
    server_mounted_mirror  = var.server_mounted_mirror
    server_username                = var.server_username
    server_password                = var.server_password
    java_debugging                 = var.java_debugging
    skip_changelog_import          = var.skip_changelog_import
    create_first_user              = var.create_first_user
    mgr_sync_autologin             = var.mgr_sync_autologin
    create_sample_channel          = var.create_sample_channel
    create_sample_activation_key   = var.create_sample_activation_key
    create_sample_bootstrap_script = var.create_sample_bootstrap_script
    publish_private_ssl_key        = var.publish_private_ssl_key
    auto_accept                    = var.auto_accept
  }
}

output "configuration" {
  value = {
    id              = length(module.server_containerized.configuration["ids"]) > 0 ? module.server_containerized.configuration["ids"][0] : null
    hostname        = length(module.server_containerized.configuration["hostnames"]) > 0 ? module.server_containerized.configuration["hostnames"][0] : null
    product_version = var.product_version
    username        = var.server_username
    password        = var.server_password
  }
}
