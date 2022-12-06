/*
  This module sets up a class B VPC sliced into two subnets, one public and one private.
  The private network has no Internet access.
  The public network has an Internet Gateway and accepts SSH connections from a whitelist of trusted IPs.
*/

resource "aws_vpc" "main" {
  count = var.create_network ? 1 : 0

  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}vpc"
  }
}

resource "aws_internet_gateway" "main" {
  count = var.create_network ? 1 : 0

  vpc_id = local.vpc_id

  tags = {
    Name = "${var.name_prefix}internet-gateway"
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

locals {
  vpc_id         = var.create_network ? aws_vpc.main[0].id : data.aws_vpc.selected.id
  vpc_cidr_block = var.create_network ? aws_vpc.main[0].cidr_block : data.aws_vpc.selected.cidr_block
}

resource "aws_eip" "nat_eip" {
  count = var.create_network ? 1 : 0

  vpc = true
  tags = {
    Name = "${var.name_prefix}nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  count = var.create_network ? 1 : 0

  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.name_prefix}nat"
  }
}

data "aws_nat_gateway" "default" {
  subnet_id = var.public_subnet_id
}

resource "aws_route_table" "public" {
  count = var.create_network ? 1 : 0

  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = {
    Name = "${var.name_prefix}public-route-table"
  }
}

resource "aws_route_table" "additional-public" {
  count = var.create_db_network ? 1 : 0

  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = {
    Name = "${var.name_prefix}additional-public-route-table"
  }
}

resource "aws_main_route_table_association" "vpc_internet" {
  count = var.create_network ? 1 : 0

  vpc_id         = local.vpc_id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  count = var.create_private_network ? 1 : 0

  vpc_id = local.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = data.aws_nat_gateway.default.id
  }

  tags = {
    Name = "${var.name_prefix}private-route-table"
  }
}

resource "aws_subnet" "public" {
  count = var.create_network ? 1 : 0

  availability_zone       = var.availability_zone
  vpc_id                  = local.vpc_id
  cidr_block              = "172.16.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}public-subnet"
  }
}

resource "aws_subnet" "additional-public" {
  count = var.create_db_network ? 1 : 0

  availability_zone       = var.availability_zone == "${var.region}b" ? "${var.region}a" : "${var.region}b"
  vpc_id                  = local.vpc_id
  cidr_block              = "172.16.3.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}additional-public-subnet"
  }
}

resource "aws_route_table_association" "public" {
  count = var.create_network ? 1 : 0

  subnet_id      = aws_subnet.public[0].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "additional-public" {
  count = var.create_db_network ? 1 : 0

  subnet_id      = aws_subnet.additional-public[0].id
  route_table_id = aws_route_table.additional-public[0].id
}

resource "aws_subnet" "private" {
  count = var.create_private_network ? 1 : 0

  availability_zone       = var.availability_zone
  vpc_id                  = local.vpc_id
  cidr_block              = var.private_network
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}private-subnet"
  }
}

resource "aws_route_table_association" "private" {
  count = var.create_private_network ? 1 : 0

  subnet_id      = aws_subnet.private[0].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_subnet" "private_additional" {
  count = var.create_additional_network? 1: 0

  availability_zone       = var.availability_zone
  vpc_id                  = local.vpc_id
  cidr_block              = var.additional_network
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}private-additional-subnet"
  }
}

resource "aws_security_group" "rds" {
  count = var.create_db_network? 1: 0
  name   = "rds-security-id"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}rds"
  }
}

resource "aws_db_subnet_group" "private" {
  count = var.create_db_network? 1: 0
  name       = "db_subnet"
  subnet_ids = [aws_subnet.additional-public[0].id, aws_subnet.private[0].id]

  tags = {
    Name = "${var.name_prefix}db-subnet"
  }
}

resource "aws_route_table_association" "private_additional" {
  count = var.create_additional_network? 1: 0

  subnet_id      = aws_subnet.private_additional[0].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_vpc_dhcp_options" "dhcp_options" {
  count = var.create_network ? 1 : 0

  domain_name         = var.region == "us-east-1" ? "ec2.internal" : "${var.region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = "${var.name_prefix}dhcp-option-set"
  }
}

resource "aws_vpc_dhcp_options_association" "vpc_dhcp_options" {
  count = var.create_network ? 1 : 0

  vpc_id          = local.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_options[0].id
}

resource "aws_security_group" "public" {
  count = var.create_network ? 1 : 0

  name        = "${var.name_prefix}-public-security-group"
  description = "Allow inbound connections from the private subnet; allow SSH connections from whitelisted IPs; allow all outbound connections"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = formatlist("%s/32", var.ssh_allowed_ips)
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_subnet.private[0].cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}public-security-group"
  }
}

resource "aws_security_group" "private" {
  count = var.create_private_network ? 1 : 0

  name        = "${var.name_prefix}-private-security-group"
  description = "Allow all inbound and outbound connections within the VPC"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}private-security-group"
  }
}

resource "aws_security_group" "private_additional" {
  count = var.create_additional_network? 1: 0

  name        = "${var.name_prefix}-private-additional-security-group"
  description = "Allow only internal connections"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.additional_network]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}private-additional-security-group"
  }
}

output "configuration" {
  depends_on = [aws_route_table_association.private, aws_route_table_association.private_additional , aws_route_table_association.public]
  value = merge(var.create_network ? {
    public_subnet_id             = length(aws_subnet.public) > 0? aws_subnet.public[0].id: null
    db_private_subnet_name       = length(aws_db_subnet_group.private) > 0? aws_db_subnet_group.private[0].name: null

    public_security_group_id     = length(aws_security_group.public) > 0? aws_security_group.public[0].id: null
    private_db_security_group_id = length(aws_security_group.rds) > 0? aws_security_group.rds[0].id: null
  } : {},
  var.create_private_network ? {
    private_subnet_id            = length(aws_subnet.private) > 0? aws_subnet.private[0].id: null
    private_security_group_id    = length(aws_security_group.private) > 0? aws_security_group.private[0].id: null
  } : {},
  var.create_additional_network ? {
    private_additional_subnet_id         = length(aws_subnet.private_additional) > 0? aws_subnet.private_additional[0].id: null
    private_additional_security_group_id = length(aws_security_group.private_additional) > 0? aws_security_group.private_additional[0].id: null
  } : {})
}
