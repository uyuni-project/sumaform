/*
  This module sets up a class B VPC sliced into two subnets, one public and one private.
  The private network has no Internet access.
  The public network has an Internet Gateway and accepts SSH connections from a whitelist of trusted IPs.
*/

terraform {
    required_version = "~> 0.11.7"
}

resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  availability_zone = "${var.availability_zone}"
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "172.16.0.0/17"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name_prefix}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  availability_zone = "${var.availability_zone}"
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "172.16.128.0/17"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.name_prefix}-private-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.name_prefix}-internet-gateway"
  }
}

resource "aws_route_table" "internet" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.name_prefix}-internet-route-table"
  }
}

resource "aws_main_route_table_association" "vpc_internet" {
  vpc_id = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.internet.id}"
}

resource "aws_vpc_dhcp_options" "dhcp_options" {
  domain_name = "${var.region == "us-east-1" ? "ec2.internal" : "${var.region}.compute.internal" }"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "${var.name_prefix}-dhcp-option-set"
  }
}

resource "aws_vpc_dhcp_options_association" "vpc_dhcp_options" {
  vpc_id = "${aws_vpc.main.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dhcp_options.id}"
}

resource "aws_security_group" "public" {
  name = "${var.name_prefix}-public-security-group"
  description = "Allow inbound connections from the private subnet; allow SSH connections from whitelisted IPs; allow all outbound connections"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${formatlist("%s/32", var.ssh_allowed_ips)}"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${aws_subnet.private.cidr_block}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "${var.name_prefix}-public-security-group"
  }
}

resource "aws_security_group" "private" {
  name = "${var.name_prefix}-private-security-group"
  description = "Allow all inbound and outbound connections within the VPC"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${aws_vpc.main.cidr_block}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${aws_vpc.main.cidr_block}"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "${var.name_prefix}-private-security-group"
  }
}

output "public_subnet_id" {
  value = "${aws_subnet.public.id}"
}

output "private_subnet_id" {
  value = "${aws_subnet.private.id}"
}

output "public_security_group_id" {
  value = "${aws_security_group.public.id}"
}

output "private_security_group_id" {
  value = "${aws_security_group.private.id}"
}
