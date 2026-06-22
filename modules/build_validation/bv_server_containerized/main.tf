module "server_containerized" {
  source = "../../server_containerized"

  base_configuration = var.base_configuration
  name               = var.name
  image              = var.image
  provider_settings = {
    mac    = var.mac
    memory = var.memory
    vcpu   = var.vcpu
  }
  runtime              = "podman"
  container_repository = var.container_repository
  container_image      = var.container_image
  main_disk_size       = 100

  string_registry                = var.string_registry
  repository_disk_size           = var.repository_disk_size
  database_disk_size             = var.database_disk_size
  container_tag                  = "latest"
  beta_enabled                   = false
  server_mounted_mirror          = var.mirror
  java_debugging                 = true
  auto_accept                    = false
  disable_firewall               = false
  allow_postgres_connections     = false
  skip_changelog_import          = false
  mgr_sync_autologin             = false
  create_sample_channel          = false
  create_sample_activation_key   = false
  create_sample_bootstrap_script = false
  publish_private_ssl_key        = false
  use_os_released_updates        = true
  disable_download_tokens        = false
  large_deployment               = true
  disable_auto_bootstrap         = true
  disable_auto_channel_sync      = true
  ssh_key_path                   = var.ssh_key_path
  from_email                     = "root@suse.de"
  provision                      = true

  additional_repos = var.additional_repos
}

output "configuration" {
  value = module.server_containerized.configuration
}
