resource "null_resource" "domain" {
  triggers = {
    base_configuration            = yamlencode(var.base_configuration)
    name                          = var.name
    roles                         = yamlencode(var.roles)
    use_os_released_updates       = var.use_os_released_updates
    install_salt_bundle           = var.install_salt_bundle
    additional_repos              = yamlencode(var.additional_repos)
    additional_repos_only         = var.additional_repos_only
    additional_certs              = yamlencode(var.additional_certs)
    additional_packages           = yamlencode(var.additional_packages)
    quantity                      = var.quantity
    grains                        = yamlencode(var.grains)
    swap_file_size                = var.swap_file_size
    ssh_key_path                  = var.ssh_key_path
    gpg_keys                      = yamlencode(var.gpg_keys)
    ipv6                          = yamlencode(var.ipv6)
    connect_to_base_network       = var.connect_to_base_network
    connect_to_additional_network = var.connect_to_additional_network
    image                         = var.image
    provider_settings             = yamlencode(var.provider_settings)
  }
}

output "configuration" {
  value = {
    ids       = ["1"]
    hostnames = ["domain"]
    macaddrs  = []
  }
}
