module "dhcp_dns" {
  source = "../host"

  base_configuration            = var.base_configuration
  name                          = var.name
  quantity                      = var.base_configuration["additional_network"] != null ? var.quantity : 0

  connect_to_base_network       = false
  connect_to_additional_network = true
  roles                         = ["dhcp_dns"]
  provision                     = false

  image                         = var.image
}

# The DHCP and DNS server has no direct connection to the outside, so we must download the packages on its behalf
locals {
  add_net              = var.base_configuration["additional_network"] != null ? slice(split(".", var.base_configuration["additional_network"]), 0, 3) : [ "192", "168", "0" ]
  prefix               = join(".", local.add_net)
  reverse_prefix       = join(".", reverse(local.add_net))
  resource_name_prefix = "${var.base_configuration["name_prefix"]}${var.name}"
  zypper               = "/usr/bin/zypper --non-interactive --gpg-auto-import-keys"
  # Currently only for openSUSE 15.5:
  repo                 = "https://download.opensuse.org/distribution/leap/15.5/repo/oss"
}

resource "null_resource" "standalone_provisioning" {
  connection {
    host     = "${local.prefix}.53"
    user     = "root"
    password = "linux"
    timeout  = "3m"
  }

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p /tmp/dhcp-dns/var/cache/zypp/packages/repo
      if [ -x /usr/bin/zypper ]; then
        ${local.zypper} --root /tmp/dhcp-dns addrepo ${local.repo} offline_repo ||:
        ${local.zypper} --root /tmp/dhcp-dns install --download-only dhcp-server bind
      fi
    EOT
  }

  provisioner "file" {
    source      = "/tmp/dhcp-dns/var/cache/zypp/packages/repo"
    destination = "/root"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.name} > /etc/hostname",
      "hostname ${var.name}",
      "echo 'nameserver 127.0.0.1' > /etc/resolv.conf",
      "echo 'search example.org' >> /etc/resolv.conf",
      "${local.zypper} addrepo dir:/root/repo offline_repo ||:",
      "${local.zypper} install --allow-downgrade dhcp-server bind",
      "sed -i 's!DHCPD_INTERFACE=\"\"!DHCPD_INTERFACE=\"eth0\"!' /etc/sysconfig/dhcpd",
      "sed -i 's!# include \"/etc/named.conf.include\";!include \"/etc/named.conf.include\";!' /etc/named.conf",
    ]
  }

  provisioner "file" {
    content = <<EOT
option domain-name "example.org";
option domain-name-servers ${local.prefix}.53;

subnet ${local.prefix}.0 netmask 255.255.255.0
{
  range ${local.prefix}.128 ${local.prefix}.253;
  filename "boot/pxelinux.0";
  next-server ${local.prefix}.254;
}

${join("\n", [ for index, terminal in var.terminals:
                 format("host %s\n{\n  hardware ethernet %s;\n  fixed-address %s.%d;\n}\n",
                        split(".", terminal["hostname"])[0],
                        terminal["macaddr"],
                        local.prefix,
                        index + var.first_terminal_ip)
             ])}
EOT
    destination = "/etc/dhcpd.conf"
  }

  provisioner "file" {
    content = <<EOT
zone "${local.reverse_prefix}.in-addr.arpa" {
  type master;
  file "/var/lib/named/master/db.${local.reverse_prefix}.in-addr.arpa";

  notify no;
};

zone "example.org" {
  type master;
  file "/var/lib/named/master/db.example.org";

  notify no;
};
EOT
    destination = "/var/lib/named/named.conf.include"
  }

  provisioner "file"  {
    content = <<EOT
$ORIGIN ${local.reverse_prefix}.in-addr.arpa.

@        IN SOA ${local.resource_name_prefix}.example.org. admin@example.org. (2045010101 8600 900 86000 500)
@        IN NS  ${local.resource_name_prefix}.example.org.
${local.resource_name_prefix}.example.org. IN A   ${local.prefix}.53

53       IN PTR ${local.resource_name_prefix}.example.org.
${join("\n", [ for index, terminal in var.terminals:
                 format("%-8d IN PTR %s.example.org.\n",
                        index + var.first_terminal_ip,
                        split(".", terminal["hostname"])[0])
             ])}
EOT
    destination = "/var/lib/named/master/db.1.168.192.in-addr.arpa"
  }

  provisioner "file"  {
    content = <<EOT
$ORIGIN example.org.

@        IN SOA ${local.resource_name_prefix} admin@example.org. (2045010101 8600 900 86000 500)
@        IN NS  ${local.resource_name_prefix}
${local.resource_name_prefix} IN A   ${local.prefix}.53

${join("\n", [ for index, terminal in var.terminals:
                 format("%8s IN A   %s.%d\n",
                        split(".", terminal["hostname"])[0],
                        local.prefix,
                        index + var.first_terminal_ip)
             ])}
EOT
    destination = "/var/lib/named/master/db.example.org"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl enable --now dhcpd",
      "systemctl enable --now named",
    ]
  }
}
