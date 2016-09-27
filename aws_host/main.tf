resource "aws_instance" "instance" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  count = "${var.count}"
  availability_zone = "${var.availability_zone}"
  key_name = "${var.key_name}"
  monitoring = "${var.monitoring}"
  subnet_id = "${var.private_subnet_id}"
  vpc_security_group_ids = ["${var.private_security_group_id}"]

  root_block_device {
    volume_size = "${var.volume_size}"
  }
  
  tags {
    Name = "${var.name_prefix}-${var.name}-${count.index}"
  }
}

resource "null_resource" "host_salt_configuration" {
  count = "${var.count}"

  triggers {
    instance_id = "${element(aws_instance.instance.*.id, count.index)}"
  }
  
  connection {
    host = "${element(aws_instance.instance.*.private_dns, count.index)}"
    private_key = "${var.key_file}"
    bastion_host = "${var.package_mirror_public_name}"
  }

  provisioner "file" {
    source = "salt"
    destination = "/srv/salt"
  }

  provisioner "file" {
    content = <<EOF

hostname: ${replace("${element(aws_instance.instance.*.private_dns, count.index)}", ".${var.region}.compute.internal", "")}
domain: ${var.region}.compute.internal
use-avahi: False
package-mirror: ${var.package_mirror_private_name}
version: ${var.version}
database: ${var.database}
role: ${var.role}
server: ${var.server}
iss-master: ${var.iss-master}
iss-slave: ${var.iss-slave}
for-development-only: True

EOF

    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo salt-call --local state.sls terraform-resource",
      "sudo salt-call --local state.highstate"
    ]
  }
}

output "private_names" {
  value = ["${aws_instance.instance.*.private_dns}"]
}
