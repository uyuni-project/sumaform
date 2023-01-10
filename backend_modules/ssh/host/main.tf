locals {
  resource_name_prefix = "${var.base_configuration["name_prefix"]}${var.name}"

  provider_settings = merge({
    host     = null
    user     = "root"
    password = "linux"
    port     = 22
    type     = "ssh"
    // only supportted in ssh connection
    private_key = null
    certificate = null
    host_key    = null
    },
  var.provider_settings)
}

resource "null_resource" "provisioning" {

  triggers = {
    provider_settings  = yamlencode(local.provider_settings)
    base_configuration = yamlencode(var.base_configuration)
    grains_subset = yamlencode(
      {
        timezone                  = var.base_configuration["timezone"]
        use_ntp                   = var.base_configuration["use_ntp"]
        testsuite                 = var.base_configuration["testsuite"]
        hostname                  = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}"
        roles                     = var.roles
        use_os_released_updates   = var.use_os_released_updates
        additional_repos          = var.additional_repos
        additional_repos_only     = var.additional_repos_only
        additional_certs          = var.additional_certs
        additional_packages       = var.additional_packages
        swap_file_size            = var.swap_file_size
        authorized_keys           = var.ssh_key_path
        gpg_keys                  = var.gpg_keys
        ipv6                      = var.ipv6
    })
  }

  count = var.provision ? 1 : 0

  connection {
    host     = local.provider_settings["host"]
    user     = local.provider_settings["user"]
    password = local.provider_settings["password"]
    port     = local.provider_settings["port"]
    type     = local.provider_settings["type"]
    // only supported in ssh connection
    private_key = lookup(var.provider_settings, "private_key", var.base_configuration["private_key"])
    certificate = lookup(var.provider_settings, "certificate", var.base_configuration["certificate"])
    host_key    = lookup(var.provider_settings, "host_key", var.base_configuration["host_key"])
    // ssh connection through a bastion host
    bastion_host        = lookup(var.provider_settings, "bastion_host", var.base_configuration["bastion_host"])
    bastion_host_key    = lookup(var.provider_settings, "bastion_host_key", var.base_configuration["bastion_host_key"])
    bastion_port        = lookup(var.provider_settings, "bastion_port", var.base_configuration["bastion_port"])
    bastion_user        = lookup(var.provider_settings, "bastion_user", var.base_configuration["bastion_user"])
    bastion_password    = lookup(var.provider_settings, "bastion_password", var.base_configuration["bastion_password"])
    bastion_private_key = lookup(var.provider_settings, "bastion_private_key", var.base_configuration["bastion_private_key"])
    bastion_certificate = lookup(var.provider_settings, "bastion_certificate", var.base_configuration["bastion_certificate"])

    timeout = lookup(var.provider_settings, "timeout", var.base_configuration["timeout"])
  }

  provisioner "file" {
    source      = "salt"
    destination = "/opt"
  }

  provisioner "file" {
    content = yamlencode(merge(
      {
        hostname                  = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}"
        domain                    = var.base_configuration["domain"]
        use_avahi                 = var.base_configuration["use_avahi"]
        additional_network        = var.base_configuration["additional_network"]
        timezone                  = var.base_configuration["timezone"]
        use_ntp                   = var.base_configuration["use_ntp"]
        testsuite                 = var.base_configuration["testsuite"]
        roles                     = var.roles
        use_os_released_updates   = var.use_os_released_updates
        additional_repos          = var.additional_repos
        additional_repos_only     = var.additional_repos_only
        additional_certs          = var.additional_certs
        additional_packages       = var.additional_packages
        swap_file_size            = var.swap_file_size
        authorized_keys = concat(
          var.base_configuration["ssh_key_path"] != null ? [trimspace(file(var.base_configuration["ssh_key_path"]))] : [],
          var.ssh_key_path != null ? [trimspace(file(var.ssh_key_path))] : [],
        )
        gpg_keys                      = var.gpg_keys
        connect_to_base_network       = var.connect_to_base_network
        connect_to_additional_network = var.connect_to_additional_network
        reset_ids                     = true
        ipv6                          = var.ipv6
        data_disk_device              = contains(var.roles, "suse_manager_server") || contains(var.roles, "suse_manager_proxy") || contains(var.roles, "mirror") || contains(var.roles, "jenkins") ? "vdb" : null
      },
    var.grains))
    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /opt/salt/first_deployment_highstate.sh"
    ]
  }
}

output "configuration" {
  depends_on = [null_resource.provisioning]
  value = {
    ids       = length(null_resource.provisioning) > 0 ? null_resource.provisioning.*.id : []
    hostnames = ["${local.resource_name_prefix}.${var.base_configuration["domain"]}"]
    macaddrs  = null
  }
}
