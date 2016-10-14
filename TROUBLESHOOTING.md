# Troubleshooting

## Q: how to force the re-creation of a resource?

A: you can use [Terraform's taint command](https://www.terraform.io/docs/commands/taint.html) to mark a resource to be re-created during the next `terraform apply`. To get the correct name of the module and resource use `terraform state list`:

```
$ terraform state list
...
module.suma3pg.libvirt_volume.main_disk

$ terraform taint -module=suma3pg libvirt_volume.main_disk
The resource libvirt_volume.main_disk in the module root.suma3pg has been marked as tainted!
```

## Q: how to update a base OS image with the libvirt backend?

Taint the image resource - it will be redownloaded at next apply (and any virtual machine depending on it will also be re-created).

```
$ terraform taint -module=images libvirt_volume.sles12sp1
```

## Q: how can I work around a "resource already exists" error?

Typical error message follows:

```
Error applying plan:

1 error(s) occurred:

* libvirt_network.network: Error defining libvirt network: [Code-9] [Domain-19] operation failed: network 'terraform-network' already exists with uuid
```

In this case, Terraform thinks a resource does not exist and must be created (in other words, the resource is not yet in the [Terraform state](https://www.terraform.io/docs/state/)), while in reality it's there already.

This typically happens in case of errors, or if a previous `terraform apply` failed. In those cases, there is no bug and you have to fix the situation yourself - Terraform is right about complaining the world is not in the expected state. Otherwise please file an issue with full reproduction instructions.

The most straightforward way to solve this is to delete the corresponding resource manually (eg. using `virsh` or `virt-manager` in libvirt) and then `terraform apply` the configuration again.

The other possibility would be to fix `terraform.tfstate` manually, which is sometimes possible by copypasting carefully JSON sections from backups - but in general this is error prone and discouraged.

## Q: how can I work around a "resource not found" error?

Typical error message follows:

```
Error refreshing state: 1 error(s) occurred:

* libvirt_network.network: [Code-43] [Domain-19] Network not found: no network with matching uuid
```

This means you have removed manually a Terraform-managed resource, so Terraform believes a resource should exist (it's in the [Terraform state](https://www.terraform.io/docs/state/)) but it's not. This is in general a bug, so an issue should be reported ([example](https://github.com/dmacvicar/terraform-provider-libvirt/issues/74)).

Anyway you can work around the problem by removing the resource from the Terraform state, bringing back coherence with Terraform's vision of the world and the world itself:

```
$ terraform state list
...
module.network.libvirt_network.network
...
$ terraform state rm module.network.libvirt_network.network
Item removal successful.
```

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

Fixing AppArmor issues is difficult and beyond the scope of this guide. You can disable AppArmor completely in non-security-sensitive environments by adding `security_driver = "none"` to `/etc/libvirt/qemu.conf`.
