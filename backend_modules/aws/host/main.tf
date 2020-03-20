
locals {
//  image_map = {
//    opensuse150 = "ami-005217ca13a6911ec",
//    opensuse151 = "ami-014f38181a6bc0c52",
//    sles15      = "ami-00dcdad1a10b5895a",
//    sles15sp1   = "ami-00b2f7798f4b288da",
//    centos8     = "ami-070bf7ef71fda7356",
//  }
  ami = lookup(var.base_configuration["images_ami"], var.image, var.image)

  provider_settings = merge({
    key_name        = var.base_configuration["key_name"]
    key_file        = var.base_configuration["key_file"]
    ssh_user        = var.base_configuration["ssh_user"]
    public_instance = false
    volume_size     = 50
    bastion_host    = lookup(var.base_configuration, "bastion_host", null)
    instance_type = "t2.micro" },
    contains(var.roles, "server") ? { instance_type = "t2.medium" } : {},
    contains(var.roles, "server") && lookup(var.base_configuration, "testsuite", false) ? { instance_type = "m5.large" } : {},
    contains(var.roles, "server") && lookup(var.grains, "pts", false) ? { instance_type = "t2.xlarge" } : {},
    contains(var.roles, "proxy") && lookup(var.base_configuration, "testsuite", false) ? { instance_type = "t2.medium" } : {},
    contains(var.roles, "pts_minion") ? { instance_type = "t2.medium" } : {},
    contains(var.roles, "mirror") ? { instance_type = "t2.micro" } : {},
    contains(var.roles, "controller") ? { instance_type = "t2.medium" } : {},
    contains(var.roles, "grafana") ? { instance_type = "t2.medium" } : {},
    contains(var.roles, "virthost") ? { instance_type = "t2.small" } : {},
  var.provider_settings)

  public_subnet_id          = var.base_configuration.public_subnet_id
  private_subnet_id         = var.base_configuration.private_subnet_id
  public_security_group_id  = var.base_configuration.public_security_group_id
  private_security_group_id = var.base_configuration.private_security_group_id

  resource_name_prefix = "${var.base_configuration["name_prefix"]}${var.name}"

  availability_zone = var.base_configuration["availability_zone"]
  region            = var.base_configuration["region"]
}

data "template_file" "user_data" {
  count    = var.quantity > 0 ? var.quantity : 0
  template = file("${path.module}/user_data.yaml")
  vars = {
    image           = var.image
    public_instance = local.provider_settings["public_instance"]
    mirror_url      = var.base_configuration["mirror"]
  }
}

resource "aws_instance" "instance" {
  ami                    = local.ami
  instance_type          = local.provider_settings["instance_type"]
  count                  = var.quantity
  availability_zone      = local.availability_zone
  key_name               = local.provider_settings["key_name"]
  subnet_id              = local.provider_settings["public_instance"] ? local.public_subnet_id : local.private_subnet_id
  vpc_security_group_ids = [local.provider_settings["public_instance"] ? local.public_security_group_id : local.private_security_group_id]

  root_block_device {
    volume_size = local.provider_settings["volume_size"]
  }

  user_data = data.template_file.user_data[count.index].rendered

  # HACK: ephemeral block devices are defined in any case
  # they will only be used for instance types that provide them
  ephemeral_block_device {
    device_name  = "xvdb"
    virtual_name = "ephemeral0"
  }

  ephemeral_block_device {
    device_name  = "xvdc"
    virtual_name = "ephemeral1"
  }

  tags = {
    Name = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}"
  }

  # HACK
  # SUSE internal openbare AWS accounts add special tags to identify the instance owner ("PrincipalId", "Owner").
  # After the first `apply`, terraform removes those tags. The following block avoids this behavior.
  # The correct way to do it would be by ignoring those tags, which is not supported yet by the AWS terraform provider
  # https://github.com/terraform-providers/terraform-provider-aws/issues/10689
  lifecycle {
    ignore_changes = [tags]
  }
}

/** START: Set up an extra data disk */
resource "aws_ebs_volume" "data_disk" {
  count = var.additional_disk_size == null ? 0 : var.additional_disk_size > 0 ? var.quantity : 0

  availability_zone = local.availability_zone
  size              = var.additional_disk_size == null ? 0 : var.additional_disk_size
  type              = lookup(var.volume_provider_settings, "type", "sc1")
  snapshot_id       = lookup(var.volume_provider_settings, "volume_snapshot_id", null)
  tags = {
    Name = "${local.resource_name_prefix}-data-volume${var.quantity > 1 ? "-${count.index + 1}" : ""}"
  }
  # HACK
  # SUSE internal openbare AWS accounts add special tags to identify the instance owner ("PrincipalId", "Owner").
  # After the first `apply`, terraform removes those tags. The following block avoids this behavior.
  # The correct way to do it would be by ignoring those tags, which is not supported yet by the AWS terraform provider
  # https://github.com/terraform-providers/terraform-provider-aws/issues/10689
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_volume_attachment" "data_disk_attachment" {
  depends_on = [aws_instance.instance, aws_ebs_volume.data_disk]

  count = var.additional_disk_size == null ? 0 : var.additional_disk_size > 0 ? var.quantity : 0

  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.data_disk[count.index].id
  instance_id = aws_instance.instance[count.index].id
  // volume tends not to detach, breaking terraform destroy, so skip destroying
  // volume attachment
  skip_destroy = true
}
/** END: Set up an extra data disk */

/** START: provisioning */
resource "null_resource" "host_salt_configuration" {
  depends_on = [aws_instance.instance, aws_volume_attachment.data_disk_attachment]
  count      = var.provision ? var.quantity : 0

  triggers = {
    main_volume_id = length(aws_ebs_volume.data_disk) == var.quantity ? aws_ebs_volume.data_disk[count.index].id : null
    domain_id      = length(aws_instance.instance) == var.quantity ? aws_instance.instance[count.index].id : null
    grains_subset = yamlencode(
      {
        testsuite             = var.base_configuration["testsuite"]
        roles                 = var.roles
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
    host         = aws_instance.instance[count.index].associate_public_ip_address ? aws_instance.instance[count.index].public_dns : aws_instance.instance[count.index].private_dns
    private_key  = file(local.provider_settings["key_file"])
    bastion_host = aws_instance.instance[count.index].associate_public_ip_address ? null : local.provider_settings["bastion_host"]
    user         = local.provider_settings["ssh_user"]
    timeout      = "120s"
  }

//  provisioner "remote-exec" {
//    inline = ["cloud-init status --wait ||:"]
//  }

  provisioner "file" {
    source      = "salt"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/salt/wait_for_salt.sh",
    ]
  }

  provisioner "file" {

    content = yamlencode(merge(
      {
        hostname : replace(aws_instance.instance[count.index].private_dns, ".${local.region == "us-east-1" ? "ec2.internal" : "${local.region}.compute.internal"}", "")
        domain : local.region == "us-east-1" ? "ec2.internal" : "${local.region}.compute.internal"
        use_avahi : false

        //        hostname                  = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}"
        //        domain                    = var.base_configuration["domain"]
        //        use_avahi                 = var.base_configuration["use_avahi"]
        //        additional_network        = var.base_configuration["additional_network"]
        timezone                  = var.base_configuration["timezone"]
        testsuite                 = var.base_configuration["testsuite"]
        roles                     = var.roles
        use_os_released_updates   = var.use_os_released_updates
        use_os_unreleased_updates = var.use_os_unreleased_updates
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
        data_disk_device              = contains(var.roles, "server") || contains(var.roles, "proxy") || contains(var.roles, "mirror") ? "xvdf" : null
      },
    var.grains))
    destination = "/tmp/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/grains /etc/salt/grains",
      "sudo mv /tmp/salt /root",
      "sudo bash /root/salt/first_deployment_highstate.sh"
    ]
  }
}

/** END: provisioning */

output "configuration" {
  depends_on = [aws_instance.instance, null_resource.host_salt_configuration]
  value = {
    ids          = length(aws_instance.instance) > 0 ? aws_instance.instance[*].id : []
    hostnames    = length(aws_instance.instance) > 0 ? aws_instance.instance.*.private_dns : []
    public_names = length(aws_instance.instance) > 0 ? aws_instance.instance.*.public_dns : []
    macaddrs     = length(aws_instance.instance) > 0 ? aws_instance.instance.*.private_ip : []
  }
}
