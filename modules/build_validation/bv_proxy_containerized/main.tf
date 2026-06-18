module "proxy_containerized" {
  source = "../../proxy_containerized"

  base_configuration = var.base_configuration
  name               = var.name
  image              = var.image
  provider_settings = {
    mac    = var.mac
    memory = 4096
  }
  string_registry      = var.string_registry
  runtime              = "podman"
  container_repository = var.container_repository
  container_tag        = "latest"
  auto_configure       = false
  ssh_key_path         = var.ssh_key_path
  provision            = true

  additional_repos = var.additional_repos
}

output "configuration" {
  value = module.proxy_containerized.configuration
}
