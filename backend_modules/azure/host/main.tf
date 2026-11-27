
locals {
  // arm64 images need an Ampere/Cobalt VM size
  arm            = length(regexall("arm64", var.image)) > 0
  platform_image = lookup(lookup(var.base_configuration["platform_image_info"], var.image, {}), "platform_image", var.image)
  // purchase plan of Marketplace images that have one, null otherwise
  plan           = lookup(lookup(var.base_configuration["platform_image_info"], var.image, {}), "plan", null)
  disk_snapshot  = lookup(var.volume_provider_settings, "volume_snapshot", null)
  provider_settings = merge({
    public_key_location    = var.base_configuration["public_key_location"]
    key_file               = var.base_configuration["key_file"]
    ssh_user               = lookup(lookup(var.base_configuration["platform_image_info"], var.image, {}), "ssh_user", "azureuser")
    volume_size            = var.main_disk_size
    bastion_host           = lookup(var.base_configuration, "bastion_host", null)
    disk_encryption_set_id = lookup(var.base_configuration, "disk_encryption_set_id", null)
    vm_size = lookup(var.provider_settings, "vm_size", "Standard_B1s") },
    contains(var.roles, "server_containerized") ? { vm_size = local.arm ? "Standard_D8ps_v5" : "Standard_D8as_v5" } : {},
    contains(var.roles, "proxy_containerized") ? { vm_size = local.arm ? "Standard_D2pls_v5" : "Standard_F2s_v2" } : {},
    contains(var.roles, "mirror") ? { vm_size = "Standard_B1s" } : {},
    contains(var.roles, "controller") ? { vm_size = "Standard_B2s" } : {},
    contains(var.roles, "grafana") ? { vm_size = "Standard_B2s" } : {},
    contains(var.roles, "virthost") ? { vm_size = "Standard_B1ms" } : {},
    contains(var.roles, "jenkins") ? { vm_size = "Standard_B4ms" } : {},
  var.provider_settings)
  additional_network           = var.base_configuration.additional_network
  public_subnet_id             = var.base_configuration.public_subnet_id
  private_subnet_id            = var.base_configuration.private_subnet_id
  private_additional_subnet_id = var.base_configuration.private_additional_subnet_id
  resource_group_name          = var.base_configuration.resource_group_name
  resource_name_prefix         = "${var.base_configuration["name_prefix"]}${var.name}"
  public_instance              = lookup(var.provider_settings, "public_instance", false)
  location                     = var.base_configuration["location"]
  product_version              = var.product_version != null ? var.product_version : var.base_configuration["product_version"]

  user_data = templatefile("${path.module}/user_data.yaml", {
    image           = var.image
    public_instance = local.public_instance
    tools_repo      = lookup(lookup(var.base_configuration["platform_image_info"], var.image, {}), "tools_repo", "")
  })
}

resource "azurerm_public_ip" "suma-pubIP" {
  count               = local.public_instance ? var.quantity : 0
  name                = "${var.base_configuration["name_prefix"]}${var.name}-pubIP${count.index}"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"
  sku                 = "Standard" # Basic SKU public IPs are retired

  tags = {
    environment = "qe"
  }
}

resource "azurerm_network_interface" "suma-main-nic" {
  count               = var.quantity
  name                = "${var.base_configuration["name_prefix"]}${var.name}-main-nic${count.index}"
  location            = local.location
  resource_group_name = local.resource_group_name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.connect_to_base_network ? (local.public_instance ? local.public_subnet_id : local.private_subnet_id) : var.connect_to_additional_network ? local.private_additional_subnet_id : local.private_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = local.public_instance ? azurerm_public_ip.suma-pubIP[count.index].id : null
  }
}

resource "azurerm_network_interface" "suma-additional-nic" {
  count               = var.connect_to_base_network && var.connect_to_additional_network && local.additional_network != null ? var.quantity : 0
  name                = "${var.base_configuration["name_prefix"]}${var.name}-additional-nic${count.index}"
  location            = local.location
  resource_group_name = local.resource_group_name
  ip_configuration {
    name                          = "internal-additional"
    subnet_id                     = local.private_additional_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "instance" {
  count = var.quantity
  name  = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}"

  location                        = local.location
  resource_group_name             = local.resource_group_name
  network_interface_ids           = concat([azurerm_network_interface.suma-main-nic[count.index].id], length(azurerm_network_interface.suma-additional-nic) > 0 ? [azurerm_network_interface.suma-additional-nic[count.index].id] : [])
  size                            = local.provider_settings["vm_size"]
  admin_username                  = "azureuser"
  disable_password_authentication = true
  custom_data                     = base64encode(local.user_data)
  os_disk {
    name                   = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}-os-disk"
    caching                = "ReadWrite"
    disk_size_gb           = local.provider_settings["volume_size"]
    storage_account_type   = "Standard_LRS"
    disk_encryption_set_id = local.provider_settings["disk_encryption_set_id"]
  }
  source_image_reference {
    publisher = local.platform_image.publisher
    offer     = local.platform_image.offer
    sku       = local.platform_image.sku
    version   = local.platform_image.version
  }
  dynamic "plan" {
    for_each = local.plan == null ? [] : [local.plan]
    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }
  admin_ssh_key {
    username   = "azureuser"
    public_key = file(local.provider_settings["public_key_location"])
  }
  lifecycle {
    precondition {
      condition     = contains(keys(var.base_configuration["platform_image_info"]), var.image)
      error_message = "Image \"${var.image}\" is not available on Azure, use one of: ${join(", ", sort(keys(var.base_configuration["platform_image_info"])))}."
    }
  }
}


/** START: Set up extra data disks */
resource "azurerm_managed_disk" "addtionaldisks" {
  count                  = var.additional_disk_size > 0 ? var.quantity : 0
  name                   = "${local.resource_name_prefix}-data-volume${var.quantity > 1 ? "-${count.index + 1}" : ""}"
  location               = local.location
  resource_group_name    = local.resource_group_name
  storage_account_type   = "Standard_LRS"
  create_option          = local.disk_snapshot == null ? "Empty" : "Copy"
  source_resource_id     = local.disk_snapshot == null ? null : local.disk_snapshot.id
  disk_size_gb           = var.additional_disk_size > 0 ? var.additional_disk_size : (local.disk_snapshot == null ? 0 : local.disk_snapshot.disk_size_gb)
  disk_encryption_set_id = local.provider_settings["disk_encryption_set_id"]
  // no SAS export/import of disk data from the Internet: sumaform never needs it
  public_network_access_enabled = false
  network_access_policy         = "DenyAll"
}

// LUNs must match the data_disk_device / second_data_disk_device grains below
resource "azurerm_virtual_machine_data_disk_attachment" "addtionaldisks-attach" {
  count              = length(azurerm_managed_disk.addtionaldisks)
  managed_disk_id    = azurerm_managed_disk.addtionaldisks[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.instance[count.index].id
  lun                = 0
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "second-additionaldisks" {
  count                  = var.second_additional_disk_size > 0 ? var.quantity : 0
  name                   = "${local.resource_name_prefix}-second-data-volume${var.quantity > 1 ? "-${count.index + 1}" : ""}"
  location               = local.location
  resource_group_name    = local.resource_group_name
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = var.second_additional_disk_size
  disk_encryption_set_id = local.provider_settings["disk_encryption_set_id"]
  // no SAS export/import of disk data from the Internet: sumaform never needs it
  public_network_access_enabled = false
  network_access_policy         = "DenyAll"
}

resource "azurerm_virtual_machine_data_disk_attachment" "second-additionaldisks-attach" {
  count              = length(azurerm_managed_disk.second-additionaldisks)
  managed_disk_id    = azurerm_managed_disk.second-additionaldisks[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.instance[count.index].id
  lun                = 1
  caching            = "ReadWrite"
}
/** END: Set up extra data disks */

/** START: provisioning */
resource "terraform_data" "host_salt_configuration" {
  depends_on = [azurerm_linux_virtual_machine.instance, azurerm_virtual_machine_data_disk_attachment.addtionaldisks-attach, azurerm_virtual_machine_data_disk_attachment.second-additionaldisks-attach]
  count      = var.provision ? var.quantity : 0

  triggers_replace = {
    main_volume_id = length(azurerm_managed_disk.addtionaldisks) == var.quantity ? azurerm_managed_disk.addtionaldisks[count.index].id : null
    domain_id      = length(azurerm_linux_virtual_machine.instance) == var.quantity ? azurerm_linux_virtual_machine.instance[count.index].id : null
    grains_subset = yamlencode(
      {
        timezone              = var.base_configuration["timezone"]
        use_ntp               = var.base_configuration["use_ntp"]
        testsuite             = var.base_configuration["testsuite"]
        roles                 = var.roles
        install_salt_bundle   = var.install_salt_bundle
        additional_repos      = var.additional_repos
        additional_repos_only = var.additional_repos_only
        additional_certs      = var.additional_certs
        additional_packages   = var.additional_packages
        swap_file_size        = var.swap_file_size
        authorized_keys       = var.ssh_key_path
        gpg_keys              = var.gpg_keys
        ipv6                  = var.ipv6
    })
  }
  connection {
    host        = local.public_instance ? azurerm_public_ip.suma-pubIP[count.index].ip_address : azurerm_network_interface.suma-main-nic[count.index].private_ip_address
    private_key = file(local.provider_settings["key_file"])
    user        = local.provider_settings["ssh_user"]

    bastion_host        = local.public_instance ? null : local.provider_settings["bastion_host"]
    bastion_user        = "azureuser"
    bastion_private_key = file(local.provider_settings["key_file"])
    timeout             = "120s"
  }

  provisioner "file" {
    source      = "salt"
    destination = "/tmp"
  }

  provisioner "file" {
    content = yamlencode(merge(
      {
        hostname  = azurerm_linux_virtual_machine.instance[count.index].name
        domain    = azurerm_network_interface.suma-main-nic[count.index].internal_domain_name_suffix
        use_avahi = false

        timezone                = var.base_configuration["timezone"]
        use_ntp                 = var.base_configuration["use_ntp"]
        testsuite               = var.base_configuration["testsuite"]
        roles                   = var.roles
        product_version         = local.product_version
        use_os_released_updates = var.use_os_released_updates
        additional_repos        = var.additional_repos
        additional_repos_only   = var.additional_repos_only
        additional_certs        = var.additional_certs
        additional_packages     = var.additional_packages
        install_salt_bundle     = var.install_salt_bundle
        swap_file_size          = var.swap_file_size
        authorized_keys = concat(
          var.base_configuration["ssh_key_path"] != null ? [trimspace(file(var.base_configuration["ssh_key_path"]))] : [],
          var.ssh_key_path != null ? [trimspace(file(var.ssh_key_path))] : [],
        )
        gpg_keys                      = var.gpg_keys
        connect_to_base_network       = var.connect_to_base_network
        connect_to_additional_network = var.connect_to_additional_network
        reset_ids                     = true
        ipv6                          = var.ipv6
        // stable udev symlinks by LUN: sdX names are not stable on Azure, and sdb is often the ephemeral resource disk
        data_disk_device        = contains(var.roles, "server_containerized") || contains(var.roles, "proxy_containerized") || contains(var.roles, "mirror") || contains(var.roles, "jenkins") ? "disk/azure/scsi1/lun0" : null
        second_data_disk_device = contains(var.roles, "server_containerized") || contains(var.roles, "proxy_containerized") || contains(var.roles, "mirror") || contains(var.roles, "jenkins") ? "disk/azure/scsi1/lun1" : null
      },
    var.grains))
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
}

/** END: provisioning */

output "configuration" {
  depends_on = [azurerm_linux_virtual_machine.instance, terraform_data.host_salt_configuration]
  value = {
    ids          = length(azurerm_linux_virtual_machine.instance) > 0 ? azurerm_linux_virtual_machine.instance[*].id : []
    hostnames    = length(azurerm_linux_virtual_machine.instance) > 0 ? azurerm_network_interface.suma-main-nic[*].private_ip_address : []
    public_names = length(azurerm_linux_virtual_machine.instance) > 0 ? azurerm_public_ip.suma-pubIP[*].ip_address : []
    macaddrs     = length(azurerm_linux_virtual_machine.instance) > 0 ? azurerm_network_interface.suma-main-nic[*].mac_address : []
  }
}
