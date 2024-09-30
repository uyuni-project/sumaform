locals {
  name_prefix       = var.base_configuration["name_prefix"]
  domain            = var.base_configuration["domain"]
  ssh_key_path      = var.base_configuration["ssh_key_path"]
  provider_settings = merge({
    userid   = null
    memory   = "2G"
    vcpu     = 1
    mac      = null
    ssh_user = "root"
    key_file = var.base_configuration["key_file"]
    },
    var.provider_settings)
}

resource "feilong_cloudinit_params" "s390_params" {
  name       = "${local.name_prefix}${var.name}"

  hostname   = "${local.name_prefix}${var.name}.${local.domain}"
  public_key = trimspace(file(local.ssh_key_path))
}

resource "feilong_guest" "s390_guest" {
  depends_on = [ feilong_cloudinit_params.s390_params ]

  name       = "${local.name_prefix}${var.name}"

  memory     = local.provider_settings["memory"]
  disk       = "12G"
  vcpus      = local.provider_settings["vcpu"]
  image      = var.image
  userid     = local.provider_settings["userid"]
  mac        = local.provider_settings["mac"]
  vswitch    = local.provider_settings["vswitch"]

  cloudinit_params = feilong_cloudinit_params.s390_params.file
}

resource "null_resource" "provisioning" {
  depends_on = [ feilong_guest.s390_guest ]

  triggers = {
  }

  connection {
    host        = feilong_guest.s390_guest.ip_address
    private_key = file(local.provider_settings["key_file"])
    user        = local.provider_settings["ssh_user"]
  }

  provisioner "file" {
    source      = "salt"
    destination = "/tmp"
  }

  provisioner "file" {
    content = yamlencode(
      {
        hostname                      = "${local.name_prefix}${var.name}"
        domain                        = local.domain
        use_avahi                     = false
        provider                      = "feilong"
        roles                         = var.roles
        product_version               = var.product_version
        use_os_released_updates       = var.use_os_released_updates
        additional_repos              = var.additional_repos
        additional_repos_only         = var.additional_repos_only
        additional_certs              = var.additional_certs
        additional_packages           = var.additional_packages
        install_salt_bundle           = var.install_salt_bundle
        swap_file_size                = var.swap_file_size
        authorized_keys               = concat(
          local.ssh_key_path != null ? [ trimspace(file(local.ssh_key_path)) ] : [],
          var.ssh_key_path != null   ? [ trimspace(file(var.ssh_key_path)) ] : [],
        )
        gpg_keys                      = var.gpg_keys
        connect_to_base_network       = true
        connect_to_additional_network = false
        reset_ids                     = true
        ipv6                          = var.ipv6

        // These should be defined in a "sumaform module", but we cannot use sumaform modules,
        // because "backend" symbolic link probably points to a different backend module :-(
        timezone                      = "Europe/Berlin"
        use_ntp                       = true
    })
    destination = "/tmp/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /tmp/salt/wait_for_salt.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /root/salt",
      "sudo mv /tmp/salt /root",
      "sudo bash /root/salt/first_deployment_highstate.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash -c 'echo root:linux | chpasswd'",
      "sudo bash -c 'sed -i \"/Please login as the user ..sles.. rather than the user ..root../d\" /root/.ssh/authorized_keys'"
    ]
  }
}

output "configuration" {
  depends_on  = [ feilong_guest.s390_guest, null_resource.provisioning ]
  value = {
    ids       = [ feilong_guest.s390_guest.userid               ]
    hostnames = [ feilong_cloudinit_params.s390_params.hostname ]
    macaddrs  = [ feilong_guest.s390_guest.mac_address          ]
    ipaddrs  =  [ feilong_guest.s390_guest.ip_address           ]
  }
}
