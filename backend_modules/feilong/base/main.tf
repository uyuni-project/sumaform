locals {
  name_prefix       = var.name_prefix
  domain            = var.domain
  ssh_key_path      = var.ssh_key_path
  key_file          = lookup(var.provider_settings, "key_file", "~/.ssh/id_rsa")
  product_version   = var.product_version
}

output "configuration" {
  value = {
    name_prefix     = local.name_prefix
    domain          = local.domain
    ssh_key_path    = local.ssh_key_path
    key_file        = local.key_file
    product_version = local.product_version
  }
}
