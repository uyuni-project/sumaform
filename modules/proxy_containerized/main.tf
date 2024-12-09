variable "images" {
  default = {
    "head"           = "slemicro55o"
    "5.0-released"   = "slemicro55o"
    "5.0-nightly"    = "slemicro55o"
    "uyuni-master"   = "leapmicro55o"
    "uyuni-released" = "leapmicro55o"
    "uyuni-pr"       = "leapmicro55o"
  }
}

locals {
  product_version = var.product_version != null ? var.product_version : var.base_configuration["product_version"]
}

module "proxy_containerized" {
  source = "../host"

  roles                         = var.roles
  connect_to_base_network       = true
  connect_to_additional_network = true
  quantity                      = var.quantity
  base_configuration            = var.base_configuration
  image                         = var.image == "default" || local.product_version == "head" ? var.images[local.product_version] : var.image
  name                          = var.name
  use_os_released_updates       = var.use_os_released_updates
  install_salt_bundle           = var.install_salt_bundle
  ssh_key_path                  = var.ssh_key_path
  additional_repos              = var.additional_repos
  additional_repos_only         = var.additional_repos_only
  additional_packages           = var.additional_packages
  provider_settings             = var.provider_settings
  additional_disk_size          = var.repository_disk_size
  second_additional_disk_size   = var.database_disk_size
  volume_provider_settings      = var.volume_provider_settings
  provision                     = var.provision

  grains = {
    server                    = var.server_configuration["hostname"]
    server_username           = var.server_configuration["username"]
    server_password           = var.server_configuration["password"]
    auto_configure            = var.auto_configure
    container_runtime         = var.runtime
    container_repository      = var.container_repository
    container_tag             = var.container_tag
    helm_chart_url            = var.helm_chart_url # Not yet implemented in sumaform salt states
    mirror                    = var.base_configuration["mirror"]
    avahi_reflector           = var.avahi_reflector
    main_disk_size            = var.main_disk_size
    repository_disk_size      = var.repository_disk_size
    database_disk_size        = var.database_disk_size
    proxy_registration_code   = var.proxy_registration_code
  }
}

output "configuration" {
  value = {
    id                   = length(module.proxy_containerized.configuration["ids"]) > 0 ? module.proxy_containerized.configuration["ids"][0] : null
    hostname             = length(module.proxy_containerized.configuration["hostnames"]) > 0 ? module.proxy_containerized.configuration["hostnames"][0] : null
    private_mac          = length(module.proxy_containerized.configuration["private_macs"]) > 0 ? module.proxy_containerized.configuration["private_macs"][0]: null
    private_ip           = 254
    private_name         = "proxy"
    username             = var.server_configuration["username"]
    password             = var.server_configuration["password"]
    runtime              = var.runtime
    container_repository = var.container_repository
    auto_configure       = var.auto_configure
  }
}
