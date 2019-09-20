terraform {
    required_version = "~> 0.11.7"
}

resource "aws_instance" "instance" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  count = "${var.quantity}"
  availability_zone = "${var.availability_zone}"
  key_name = "${var.key_name}"
  subnet_id = "${var.private_subnet_id}"
  vpc_security_group_ids = ["${var.private_security_group_id}"]

  root_block_device {
    volume_size = "${var.volume_size}"
  }

  # HACK: ephemeral block devices are defined in any case
  # they will only be used for instance types that provide them
  ephemeral_block_device {
    device_name = "xvdb"
    virtual_name = "ephemeral0"
  }

  ephemeral_block_device {
    device_name = "xvdc"
    virtual_name = "ephemeral1"
  }

  tags {
    Name = "${var.name_prefix}-${var.name}-${count.index}"
  }
}

resource "null_resource" "host_salt_configuration" {
  count = "${var.quantity}"

  connection {
    host = "${element(aws_instance.instance.*.private_dns, count.index)}"
    private_key = "${file(var.key_file)}"
    bastion_host = "${var.mirror_public_name}"
  }

  provisioner "file" {
    source = "salt"
    destination = "/root"
  }

  provisioner "file" {
    content = <<EOF

hostname: ${replace("${element(aws_instance.instance.*.private_dns, count.index)}", ".${var.region == "us-east-1" ? "ec2.internal" : "${var.region}.compute.internal"}", "")}
domain: ${var.region == "us-east-1" ? "ec2.internal" : "${var.region}.compute.internal"}
use_avahi: False
mirror: ${var.mirror_private_name}
product_version: ${var.product_version}
channels: [${join(",", var.channels)}]
roles: [${join(",", var.roles)}]
cc_username: ${var.cc_username}
cc_password: ${var.cc_password}
server: ${var.server}
iss_master: ${var.iss_master}
iss_slave: ${var.iss_slave}
unsafe_postgres: ${var.unsafe_postgres}
auto_accept: ${var.auto_accept}
monitored: ${var.monitored}
apparmor: ${var.apparmor}
timezone: ${var.timezone}
authorized_keys: null
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
gpg_keys:  [${join(", ", formatlist("'%s'", var.gpg_keys))}]
reset_ids: true

susemanager:
  activation_key: ${var.activation_key}

EOF

    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sh /root/salt/first_deployment_highstate.sh"
    ]
  }
}

output "private_names" {
  value = "${aws_instance.instance.*.private_dns}"
}
