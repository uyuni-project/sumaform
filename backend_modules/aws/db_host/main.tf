
locals {

  provider_settings = merge({
    key_name        = var.base_configuration["key_name"]
    key_file        = var.base_configuration["key_file"]
    ssh_user        = "ec2-user"
    public_instance = false
    volume_size     = 50
    bastion_host    = lookup(var.base_configuration, "bastion_host", null)
    instance_class = "db.t3.micro" },
  var.provider_settings
  )

  public_subnet_id                     = var.base_configuration.public_subnet_id
  private_subnet_id                    = var.base_configuration.private_subnet_id
  private_additional_subnet_id         = var.base_configuration.private_additional_subnet_id
  db_private_subnet_name               = var.base_configuration.db_private_subnet_name
  public_security_group_id             = var.base_configuration.public_security_group_id
  private_security_group_id            = var.base_configuration.private_security_group_id
  private_additional_security_group_id = var.base_configuration.private_additional_security_group_id

  resource_name_prefix = "${var.base_configuration["name_prefix"]}${var.name}"

  availability_zone = var.base_configuration["availability_zone"]
  region            = var.base_configuration["region"]
}

resource "aws_db_instance" "instance" {
  instance_class         = local.provider_settings["instance_class"]
  count                  = var.quantity
  identifier             = local.resource_name_prefix
  db_subnet_group_name   = local.db_private_subnet_name
  vpc_security_group_ids = [var.connect_to_base_network ? (local.provider_settings["public_instance"] ? local.public_security_group_id : local.private_security_group_id) : var.connect_to_additional_network ? local.private_additional_security_group_id : local.private_security_group_id]
  engine                 = var.engine
  engine_version         = var.engine_version
  username               = var.db_username
  password               = var.db_password

  publicly_accessible    = var.publicly_accessible
  skip_final_snapshot    = var.skip_final_snapshot

  allocated_storage = local.provider_settings["volume_size"]

  tags = {
    Name = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

output "configuration" {
  depends_on = [aws_db_instance.instance]
  value = {
    ids          = length(aws_db_instance.instance) > 0 ? aws_db_instance.instance[*].id : []
    hostnames    = length(aws_db_instance.instance) > 0 ? aws_db_instance.instance.*.address : []
    ca           = length(aws_db_instance.instance) > 0 ? aws_db_instance.instance.*.ca_cert_identifier : []
    username     = length(aws_db_instance.instance) > 0 ? aws_db_instance.instance.*.username : []
    port         = length(aws_db_instance.instance) > 0 ? aws_db_instance.instance.*.port : []
  }
}
