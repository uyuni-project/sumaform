// TODO: This module is a copy/paste of the server module and some variables are not yet implemented, some could also be dropped, work in-progress.

variable "images" {
  default = {
    "head"           = "slmicro61o"
    "5.0-released"   = "slemicro55o"
    "5.0-nightly"    = "slemicro55o"
    "5.1-released"   = "slmicro61o"
    "5.1-nightly"    = "slmicro61o"
    "uyuni-master"   = "tumbleweedo"
    "uyuni-released" = "tumbleweedo"
    "uyuni-pr"       = "tumbleweedo"
  }
}

locals {
  product_version = var.product_version != null ? var.product_version : var.base_configuration["product_version"]
}

module "server_kubernetes" {
  source = "../host"

  base_configuration            = var.base_configuration
  name                          = var.name
  roles                         = ["server_kubernetes"]
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
  image                         = var.image == "default" ? var.images[local.product_version] : var.image
  provision                     = var.provision
  provider_settings             = var.provider_settings
  main_disk_size                = var.main_disk_size
  additional_disk_size          = var.repository_disk_size
  second_additional_disk_size   = var.database_disk_size
  volume_provider_settings      = var.volume_provider_settings
  product_version               = local.product_version

  grains = {
    container_runtime              = var.runtime
    container_repository           = var.container_repository
    container_image                = var.container_image
    container_tag                  = var.container_tag
    db_container_repository        = var.db_container_repository
    db_container_image             = var.db_container_image
    db_container_tag               = var.db_container_tag
    helm_chart_url                 = var.helm_chart_url
    helm_chart_name                = var.helm_chart_name  
    cc_username                    = var.base_configuration["cc_username"]
    cc_password                    = var.base_configuration["cc_password"]
    channels                       = var.channels
    mirror                         = var.base_configuration["mirror"]
    server_mounted_mirror          = var.server_mounted_mirror
    server_username                = var.server_username
    server_password                = var.server_password
    java_debugging                 = var.java_debugging
    java_hibernate_debugging       = var.java_hibernate_debugging
    java_salt_debugging            = var.java_salt_debugging
    from_email                     = var.from_email
    traceback_email                = var.traceback_email
    main_disk_size                 = var.main_disk_size
    repository_disk_size           = var.repository_disk_size
    database_disk_size             = var.database_disk_size
    skip_changelog_import          = var.skip_changelog_import
    create_first_user              = true
    mgr_sync_autologin             = var.mgr_sync_autologin
    create_sample_channel          = var.create_sample_channel
    create_sample_activation_key   = var.create_sample_activation_key
    create_sample_bootstrap_script = var.create_sample_bootstrap_script
    publish_private_ssl_key        = var.publish_private_ssl_key
    auto_accept                    = var.auto_accept
    disable_auto_bootstrap         = var.disable_auto_bootstrap
    disable_auto_channel_sync      = var.disable_auto_channel_sync
    large_deployment               = var.large_deployment
    string_registry                = var.string_registry
    beta_enabled                   = var.beta_enabled
    additional_repos               = var.additional_repos
    enable_oval_metadata           = var.enable_oval_metadata
  }
}

output "configuration" {
  value = {
    id                 = length(module.server_kubernetes.configuration["ids"]) > 0 ? module.server_kubernetes.configuration["ids"][0] : null
    hostname           = length(module.server_kubernetes.configuration["hostnames"]) > 0 ? module.server_kubernetes.configuration["hostnames"][0] : null
    username           = var.server_username
    password           = var.server_password
    runtime            = var.runtime
    product_version    = local.product_version
    first_user_present = true
  }
}
