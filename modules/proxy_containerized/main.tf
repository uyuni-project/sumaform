variable "images" {
  default = {
    "head"           = "slemicro55o"
    // TODO: Replace Uyuni images with OpenSUSE Leap Micro 15.5 images
    // (not yet supported in sumaform)
    "uyuni-master"   = "opensuse155o"
    "uyuni-released" = "opensuse155o"
    "uyuni-pr"       = "opensuse155o"
  }
}

module "proxy_containerized" {
  source = "../host"

  roles                         = var.roles
  connect_to_base_network       = true
  connect_to_additional_network = true
  quantity                      = var.quantity
  base_configuration            = var.base_configuration
  image                         = var.image == "default" || var.product_version == "head" ? var.images[var.product_version] : var.image
  name                          = var.name
  use_os_released_updates       = true
  ssh_key_path                  = var.ssh_key_path
  additional_repos              = var.additional_repos
  additional_repos_only         = var.additional_repos_only
  additional_packages           = var.additional_packages
  provider_settings             = var.provider_settings
  additional_disk_size          = var.repository_disk_size
  second_additional_disk_size   = var.database_disk_size
  volume_provider_settings      = var.volume_provider_settings

  grains = {
    product_version           = var.product_version
    server                    = var.server_configuration["hostname"]
    first_user_present        = var.server_configuration["create_first_user"]
    server_username           = var.server_configuration["username"]
    server_password           = var.server_configuration["password"]
    auto_configure            = var.auto_configure
    container_runtime         = var.runtime
    container_repository      = var.container_repository
    helm_chart_url            = var.helm_chart_url # Not yet implemented in sumaform salt states
    mirror                    = var.base_configuration["mirror"]
    avahi_reflector           = var.avahi_reflector
    main_disk_size            = var.main_disk_size
    repository_disk_size      = var.repository_disk_size
    database_disk_size        = var.database_disk_size
  }
}

output "configuration" {
  value = {
    id                   = length(module.proxy_containerized.configuration["ids"]) > 0 ? module.proxy_containerized.configuration["ids"][0] : null
    hostname             = length(module.proxy_containerized.configuration["hostnames"]) > 0 ? module.proxy_containerized.configuration["hostnames"][0] : null
    product_version      = var.product_version
    username             = var.server_configuration["username"]
    password             = var.server_configuration["password"]
    runtime              = var.runtime
    container_repository = var.container_repository
    auto_configure       = var.auto_configure
  }
}
