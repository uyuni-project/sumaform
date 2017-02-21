# Troubleshooting

## Q: I get the error "* Unknown root level key: terraform" whenever I try to `terraform apply`

A: please update your terraform version to >= 0.8.0

## Q: how to force the re-creation of a resource?

A: you can use [Terraform's taint command](https://www.terraform.io/docs/commands/taint.html) to mark a resource to be re-created during the next `terraform apply`. To get the correct name of the module and resource use `terraform state list`:

```
$ terraform state list
...
module.suma3pg.module.suse_manager.libvirt_volume.main_disk

$ terraform taint -module=suma3pg.suse_manager libvirt_volume.main_disk
The resource libvirt_volume.main_disk in the module root.suma3pg.suse_manager has been marked as tainted!
```

## Q: how can I work around a "resource already exists" error?

Typical error message follows:

```
Error applying plan:

1 error(s) occurred:

* libvirt_domain.domain: Error defining libvirt domain: [Code-9] [Domain-20] operation failed: domain 'suma3pg' already exists with uuid b7ea7c0c-a2d5-4671-a2b5-ce17923ad326
```

In this case, Terraform thinks a resource does not exist and must be created (in other words, the resource is not yet in the [Terraform state](https://www.terraform.io/docs/state/)), while in reality it's there already.

This typically happens in case of errors, or if a previous `terraform apply` failed. In those cases, there is no bug and you have to fix the situation yourself — Terraform is right about complaining the world is not in the state it expects.

The most straightforward way to solve this is to delete the corresponding resource manually (eg. using `virsh undefine suma3pg` or graphically in `virt-manager` in libvirt) and then `terraform apply` the configuration again.

The other possibility would be to fix `terraform.tfstate` manually, which is sometimes possible by copypasting carefully JSON sections from backups - but in general this is error prone and discouraged.

## Q: how can I work around a "resource not found" error?

Typical error message follows:

```
Error refreshing state: 1 error(s) occurred:

* libvirt_volume.main_disk: Can't retrieve volume /var/lib/libvirt/images/suma3pg-main-disk
```

This means you have removed manually a Terraform-managed resource, so Terraform believes a resource existed (it's in the [Terraform state](https://www.terraform.io/docs/state/)) but it does not. This is in general a bug, so an issue should be reported ([example](https://github.com/dmacvicar/terraform-provider-libvirt/issues/74)).

Anyway you can work around the problem by removing the resource from the Terraform state, bringing back coherence with Terraform's vision of the world and the world itself:

```
$ terraform state list
...
module.suma3pg.module.suse_manager.libvirt_volume.main_disk
...
$ terraform state rm module.suma3pg.module.suse_manager.libvirt_volume.main_disk
Item removal successful.
```

## Q: how can I work around name resolution problems with `tf.local` mDNS/Zeroconf/Bonjour/Avahi names?

Typical error message follows:

```
Could not resolve hostname suma3pg.tf.local: Name or service not known
```

Check that:
 - your firewall is not blocking UDP port 5353
   - on SUSE systems check YaST -> Security and Users -> Firewall -> Allowed Services, "Zeroconf/Bonjour Multicast DNS" should either appear on the list or be added
 - avahi is installed and running
   - typically you can check this via systemd: `systemctl status avahi-daemon`
 - mdns is configured in glibc's Name Server Switch configuration file

In `/etc/nsswitch.conf` you should see a `hosts:` line that looks like the following:
```
hosts:          files mdns [NOTFOUND=return] dns
```
`mdns` (optionally suffixed with `4` for IPv4-only or `6` for IPv6-only) should be present in this line. If it is not, add it.

## Q: how can I work around a libvirt permission denied error?

Typical error message follows:

```
* libvirt_domain.domain: Error creating libvirt domain: [Code-1] [Domain-10]
internal error: process exited while connecting to monitor:
2016-10-14T06:49:07.518689Z qemu-system-x86_64: -drive file=/var/lib/libvirt/images/terraform_package_mirror_main_disk,format=qcow2,if=none,id=drive-virtio-disk0:
Could not open '/var/lib/libvirt/images/terraform_package_mirror_main_disk':
Permission denied
```

There are two possible causes: plain Unix permissions or AppArmor.

### Plain Unix permissions

Check that the interested directory (in the case above `/var/lib/libvirt/images`) is writable by the user running `qemu` (you can check it via `ps -eo uname:20,comm | grep qemu-system-x86` when you have at least one virtual machine running).

If the directory has wrong permissions:
 - fix their them manually via `chmod`/`chown`;
 - check that the pool definition has right user and permissions via `virsh pool-edit <POOL_NAME>` (note that mode is specified in octal and user/group as IDs, see `id -u <USERNAME>` and `cat /etc/groups`).

If the user running `qemu` is not the one you expected:
 - change the `user` and `group` variables in `/etc/libvirt/qemu.conf`, typically `root`/`root` will solve any problem
 - restart the libvirt daemon

### AppArmor

You can detect AppArmor issues by looking at `/var/log/syslog`:

```
Oct 14 08:10:03 dell kernel: [52456.461754] audit: type=1400 audit(1476425403.666:27):
apparmor="DENIED" operation="open" profile="libvirt-4d4f9b58-f50d-4f60-a8a1-315c9a2d02c1"
name="/var/lib/libvirt/images/terraform_package_mirror_main_disk"
pid=4193 comm="qemu-system-x86" requested_mask="wr" denied_mask="wr"
fsuid=106 ouid=106
```

Fixing AppArmor issues is difficult and beyond the scope of this guide. You can disable AppArmor completely in non-security-sensitive environments by adding `security_driver = "none"` to `/etc/libvirt/qemu.conf`.

## Q: how can I workaround an "expected object, got string" libvirt error during the plan?

If you run into this error:

`* libvirt_domain.domain: disk.0: expected object, got string`

during the `terraform plan`, make sure you have an up-to-date `terraform-provider-libvirt` plugin.

## Q: how can I workaround a "dial tcp" error?

If you run into this error:

`* dial tcp 192.168.122.193:22: getsockopt: network is unreachable`

during the `terraform apply`, it means Terraform was able to create a VM, but then is unable to log in via SSH do configure it. This is typically caused by network misconfiguration - `ping 192.168.122.193` should work but it does not. Please double check your networking configuration.

In particular, if you are using libvirt brigding, make sure the `network` parameter in the `base` module is uncommented and set to the empty string:

```hcl
module "base" {
  source = "./modules/libvirt/base"
  ...
  network_name = ""
  bridge = "br0"
}
```

## Q: how can I workaround an "libvirt_domain.domain: diffs didn't match during apply" libvirt error?

If you have just switched from non-bridged to bridged networking or vice versa you might get the following error:

```
Error applying plan:

1 error(s) occurred:

* libvirt_domain.domain: diffs didn't match during apply. This is a bug with Terraform and should be reported as a GitHub Issue.
...
Mismatch reason: attribute mismatch: network_interface.0.bridge
```

This is a known issue, simply repeat the `terraform apply` command and it will go away.

## Q: how do I workaround a "stat salt: no such file or directory" when applying the plan?

If you run `terraform apply` from outside of the sumaform tree, you will get the error message:

```
Error applying plan:

1 error(s) occurred:

* stat salt: no such file or directory
```

A simple solution is to create a symbolic link pointing to the `salt` directory on top level of the sumaform files tree. Create this symlink in your current directory.
