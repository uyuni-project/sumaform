/*
  This module sets up a controller host that executes the spacewalk testsuite
  against the manager server.
*/

terraform {
    required_version = "~> 0.11.7"
}

resource "aws_instance" "instance" {
  ami = "${var.ami}"
  availability_zone = "${var.availability_zone}"
  instance_type = "t2.small"
  key_name = "${var.key_name}"
  monitoring = "${var.monitoring}"
  subnet_id = "${var.public_subnet_id}"
  vpc_security_group_ids = ["${var.public_security_group_id}"]

  tags {
    Name = "${var.name_prefix}-controller"
  }
}

resource "null_resource" "controller_salt_configuration" {
  triggers {
    instance_id = "${aws_instance.instance.id}"
  }

  connection {
    host = "${aws_instance.instance.public_dns}"
    private_key = "${file(var.key_file)}"
    user = "${var.ssh_user}"
  }

  provisioner "file" {
    source = "salt"
    destination = "/tmp"
  }

  provisioner "file" {
    content = <<EOF

hostname: ${replace("${aws_instance.instance.private_dns}", ".${var.region == "us-east-1" ? "ec2.internal" : "${var.region}.compute.internal"}", "")}
domain: ${var.region == "us-east-1" ? "ec2.internal" : "${var.region}.compute.internal"}
use_avahi: False
roles: [controller]
authorized_keys: null
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_repos_only: ${var.additional_repos_only}
additional_certs: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_certs), values(var.additional_certs)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
gpg_keys:  [${join(", ", formatlist("'%s'", var.gpg_keys))}]
reset_ids: true
timezone: ${var.timezone}
git_username: ${var.git_username}
git_password: ${var.git_password}
git_repo: "${var.git_repo}"
branch: "${var.git_branch}"
server: "${var.server}"
client: "${var.client}"
minion: "${var.minion}"
repos_to_sync: "${var.repos_to_sync}"
EOF

    destination = "/tmp/grains"
  }

  provisioner "file" {
    source = "github_deploy_key"
    destination = "/tmp/github_deploy_key"
  }

  provisioner "file" {
    destination = "/tmp/ssh_config"
    content = <<EOF
host github.com
 HostName github.com
 IdentityFile ~/.ssh/github_deploy_key
 User git
 StrictHostKeyChecking no
EOF
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/grains /etc/salt/grains",
      "sudo mv /tmp/salt /root/salt",
      "sudo mv /tmp/github_deploy_key /root/.ssh/",
      "sudo chown root:root /root/.ssh/github_deploy_key",
      "sudo chmod 400 /root/.ssh/github_deploy_key",
      "sudo mv /tmp/ssh_config /root/.ssh/config",
      "sudo chown root:root /root/.ssh/config",
      "sudo chmod 400 /root/.ssh/config",
      "sudo bash /root/salt/first_deployment_highstate.sh",
      "sudo gem install parallel parallel_tests minitest",
      "sudo zypper in -y npm8",
      "sudo npm install cucumber-html-reporter"
    ]
  }
}

output "public_name" {
  value = "${aws_instance.instance.public_dns}"
}

output "private_name" {
  value = "${aws_instance.instance.private_dns}"
}
