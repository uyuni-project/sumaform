
locals {

  provider_settings = merge({
    public_instance = false
    volume_size     = 50
    instance_class = "db.t3.micro" },
  var.provider_settings
  )

  db_private_subnet_name  = var.base_configuration.db_private_subnet_name
  db_security_group_id    = var.base_configuration.private_db_security_group_id

  resource_name_prefix = "${var.base_configuration["name_prefix"]}${var.name}"
  availability_zone = var.base_configuration["availability_zone"]
}

resource "aws_db_instance" "instance" {
  instance_class         = local.provider_settings["instance_class"]
  count                  = var.quantity
  identifier             = local.resource_name_prefix
  db_subnet_group_name   = local.db_private_subnet_name
  vpc_security_group_ids = [local.db_security_group_id]
  engine                 = var.engine
  engine_version         = var.engine_version
  username               = var.db_username
  password               = var.db_password
  availability_zone      = local.availability_zone
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
    username     = length(aws_db_instance.instance) > 0 ? aws_db_instance.instance.*.username : []
    port         = length(aws_db_instance.instance) > 0 ? aws_db_instance.instance.*.port : []
  }
}
