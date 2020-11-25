variable "images" {
  default = {
    "3.2-released"   = "sles12sp4o"
    "3.2-nightly"    = "sles12sp4o"
    "4.0-released"   = "sles15sp1o"
    "4.0-nightly"    = "sles15sp1o"
    "4.1-released"   = "sles15sp2o"
    "4.1-nightly"    = "sles15sp2o"
    "4.2-beta"       = "sles15sp3o"
    "head"           = "sles15sp3o"
    "uyuni-master"   = "opensuse152o"
    "uyuni-released" = "opensuse152o"
  }
}

module "server" {
  source = "../host"

  base_configuration            = var.base_configuration
  name                          = var.name
  use_os_released_updates       = var.use_os_released_updates
  use_os_unreleased_updates     = var.use_os_unreleased_updates
  additional_repos              = var.additional_repos
  additional_repos_only         = var.additional_repos_only
  additional_certs              = var.additional_certs
  additional_packages           = var.additional_packages
  swap_file_size                = var.swap_file_size
  ssh_key_path                  = var.ssh_key_path
  gpg_keys                      = var.gpg_keys
  ipv6                          = var.ipv6
  connect_to_base_network       = true
  connect_to_additional_network = false
  roles                         = var.register_to_server == null ? ["server"] : ["server", "minion"]
  disable_firewall              = var.disable_firewall
  grains = {
    product_version        = var.product_version
    cc_username            = var.base_configuration["cc_username"]
    cc_password            = var.base_configuration["cc_password"]
    channels               = var.channels
    wait_for_reposync      = var.wait_for_reposync
    cloned_channels        = var.cloned_channels
    mirror                 = var.base_configuration["mirror"]
    iss_master             = var.iss_master
    iss_slave              = var.iss_slave
    server                 = var.register_to_server
    auto_connect_to_master = var.auto_register
    susemanager = {
      activation_key = var.activation_key
    }
    smt                            = var.smt
    server_username                = var.server_username
    server_password                = var.server_password
    allow_postgres_connections     = var.allow_postgres_connections
    unsafe_postgres                = var.unsafe_postgres
    postgres_log_min_duration      = var.postgres_log_min_duration
    java_debugging                 = var.java_debugging
    skip_changelog_import          = var.skip_changelog_import
    browser_side_less              = var.browser_side_less
    create_first_user              = var.create_first_user
    mgr_sync_autologin             = var.mgr_sync_autologin
    create_sample_channel          = var.create_sample_channel
    create_sample_activation_key   = var.create_sample_activation_key
    create_sample_bootstrap_script = var.create_sample_bootstrap_script
    publish_private_ssl_key        = var.publish_private_ssl_key
    disable_download_tokens        = var.disable_download_tokens
    auto_accept                    = var.auto_accept
    monitored                      = var.monitored
    pts                            = var.pts
    pts_minion                     = var.pts_minion
    pts_locust                     = var.pts_locust
    pts_system_count               = var.pts_system_count
    pts_system_prefix              = var.pts_system_prefix
    from_email                     = var.from_email
    traceback_email                = var.traceback_email
    saltapi_tcpdump                = var.saltapi_tcpdump
    repository_disk_size           = var.repository_disk_size
  }


  image                    = var.image == "default" || var.product_version == "head" ? var.images[var.product_version] : var.image
  provider_settings        = var.provider_settings
  additional_disk_size     = var.repository_disk_size
  volume_provider_settings = var.volume_provider_settings
}

output "configuration" {
  value = {
    id              = length(module.server.configuration["ids"]) > 0 ? module.server.configuration["ids"][0] : null
    hostname        = length(module.server.configuration["hostnames"]) > 0 ? module.server.configuration["hostnames"][0] : null
    product_version = var.product_version
    username        = var.server_username
    password        = var.server_password
  }
}
