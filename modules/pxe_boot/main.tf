module "pxe_boot" {
  source = "../backend/host"

  base_configuration = var.base_configuration
  name               = var.name
  quantity           = var.quantity
  image              = var.image

  connect_to_base_network       = false
  connect_to_additional_network = true
  roles                         = ["pxe_boot"]
  provision                     = false

  provider_settings = var.provider_settings
}

output "configuration" {
  value = {
    id       = length(module.pxe_boot.configuration["ids"]) > 0 ? module.pxe_boot.configuration["ids"][0] : null
    hostname = length(module.pxe_boot.configuration["hostnames"]) > 0 ? module.pxe_boot.configuration["hostnames"][0] : null
    macaddr = length(module.pxe_boot.configuration["macaddrs"]) > 0 ? module.pxe_boot.configuration["macaddrs"][0] : null
    image    = var.image
  }
}
