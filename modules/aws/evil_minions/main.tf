terraform {
    required_version = "~> 0.11.7"
}

resource "aws_instance" "instance" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  count = "${var.quantity}"
  availability_zone = "${var.availability_zone}"
  key_name = "${var.key_name}"
  monitoring = "${var.monitoring}"
  subnet_id = "${var.private_subnet_id}"
  vpc_security_group_ids = ["${var.private_security_group_id}"]

  root_block_device {
    volume_size = 5
    volume_type = "gp2"
  }

  tags {
    Name = "${var.name_prefix}-${var.name}-${count.index}"
  }
}

resource "null_resource" "host_salt_configuration" {
  count = "${var.quantity}"

  triggers {
    instance_id = "${element(aws_instance.instance.*.id, count.index)}"
  }

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

hostname: ${replace("${element(aws_instance.instance.*.private_dns, count.index)}", ".${var.region}.compute.internal", "")}
domain: ${var.region}.compute.internal
use_avahi: False
mirror: ${var.mirror_private_name}
product_version: 3.2-released
roles: [evil_minions]
server: ${var.server}
evil_minion_count: ${var.evil_minion_count}
slowdown_factor: ${var.slowdown_factor}
dump: ${base64encode(file(var.dump_file))}
timezone: ${var.timezone}
authorized_keys: null
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
reset_ids: true

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
