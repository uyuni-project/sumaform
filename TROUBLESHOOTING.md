# Troubleshooting

## Q: how can I work around backend not defined error?

Typical error message follows:
```
Error: Unreadable module directory

Unable to evaluate directory symlink: lstat modules/backend: no such file or directory
```

Terraform cannot find the path for the backend in use.
Create a symbolic link to the backend module directory inside the `modules` directory: `ln -sfn ../backend_modules/<BACKEND> modules/backend`

## Q: how can I work around name resolution problems with `tf.local` mDNS/Zeroconf/Bonjour/Avahi names?

Typical error message follows:

```
Could not resolve hostname server.tf.local: Name or service not known
```

Check that:
 - your firewall is not blocking UDP port 5353
  - on SUSE systems check YaST -> Security and Users -> Firewall -> Zones -> public, "mdns" should appear on the list on the right
 - avahi is installed and running
   - typically you can check this via systemd: `systemctl status avahi-daemon`
 - mdns is configured in glibc's Name Server Switch configuration file

In `/etc/nsswitch.conf` you should see a `hosts:` line that looks like the following:
```
hosts:          files mdns [NOTFOUND=return] dns
```
`mdns` (optionally suffixed with `4` for IPv4-only or `6` for IPv6-only) should be present in this line. If it is not, add it.

## Q: how can I work around slowness in resolution of `tf.local` mDNS/Zeroconf/Bonjour/Avahi names?

If there is a 5-second delay on any name resolution (or ping) between Avahi hosts, a likely cause is that ipv6 is enabled on the VMs (that is the default setting) but the network is blocking ipv6 traffic.

This can happen, for example, in libvirt if the NAT network being used does not have ipv6 enabled. Re-creating the network with ipv6 enabled fixes the problem.

## Q: how can I work around a libvirt permission denied error?

Typical error message follows:
```
* libvirt_domain.domain: Error creating libvirt domain: [Code-1] [Domain-10]
internal error: process exited while connecting to monitor:
2016-10-14T06:49:07.518689Z qemu-system-x86_64: -drive file=/var/lib/libvirt/images/mirror-main-disk,format=qcow2,if=none,id=drive-virtio-disk0:
Could not open '/var/lib/libvirt/images/mirror-main-disk':
Permission denied
```

Another possible one is:
```
* libvirt_domain.domain: Error creating libvirt domain: virError(Code=1, Domain=0, Message='internal error: child reported: Kernel does not provide mount namespace: Permission denied')
```

Yet another one is:
```
Failed to connect socket to '/var/run/libvirt/libvirt-sock': No such file or directory'
```

Some variants of this issue will also be logged in `/var/log/syslog` like:
```
Oct 14 08:10:03 dell kernel: [52456.461754] audit: type=1400 audit(1476425403.666:27):
apparmor="DENIED" operation="open" profile="libvirt-4d4f9b58-f50d-4f60-a8a1-315c9a2d02c1"
name="/var/lib/libvirt/images/terraform_mirror_main_disk"
pid=4193 comm="qemu-system-x86" requested_mask="wr" denied_mask="wr"
fsuid=106 ouid=106
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

AppArmor can be used both to isolate the host from its guests, and guests from one another. Both of those protections must be properly configured in order for sumaform to operate correctly. Unfortunately, this configuration can be difficult and is well beyond the scope of this guide. Following are instructions to disable AppArmor completely in non-security-sensitive environments.

 * host-guest protection: add `security_driver = "none"` to `/etc/libvirt/qemu.conf
 * guest-guest protection:
```sh
sudo ln -s /etc/apparmor.d/usr.sbin.libvirtd /etc/apparmor.d/disable/
sudo /etc/init.d/apparmor restart
sudo aa-status | grep libvirt # output should be empty
```

## Q: how can I workaround a "dial tcp" error?

If you run into this error:

`* dial tcp 192.168.122.193:22: getsockopt: network is unreachable`

during the `terraform apply`, it means Terraform was able to create a VM, but then is unable to log in via SSH do configure it. This is typically caused by network misconfiguration - `ping 192.168.122.193` should work but it does not. Please double check your networking configuration. If you are using AWS, make sure your current IP is listed in the `ssh_allowed_ips` variable (or check it is whitelisted in AWS Console -> VPC -> Security Groups).

## Q: how do I re-apply the Salt state that was used to provision the machine?

Run `sh /root/salt/highstate.sh`.

## Q: how to force the re-creation of a resource?

A: you can use [Terraform's taint command](https://www.terraform.io/docs/commands/taint.html) to mark a resource to be re-created during the next `terraform apply`. To get the correct name of the module and resource use `terraform state list`:

```
$ terraform state list
...
module.server.module.server.libvirt_volume.main_disk[0]

$ terraform taint module.server.module.server.libvirt_volume.main_disk[0]
Resource instance module.server.module.server.libvirt_volume.main_disk[0] has been marked as tainted.
```
## Q: how to force the re-download of an image?

A: see above, use the taint command as per the following example:

```
$ terraform state list
...
module.base.libvirt_volume.volumes[2]

$ terraform taint module.base.libvirt_volume.volumes[2]
Resource instance module.base.libvirt_volume.volumes[2] has been marked as tainted.
```

Please note that any dependent volume and module should be tainted as well before applying (eg. if you are tainting the `sles12sp2` image, make sure you either have no VMs based on that OS or that they are all tainted).

## Q: I get the error "* file: open /home/<user>/.ssh/id_rsa.pub: no such file or directory in:"

Terraform cannot find your SSH key in the default path `~/.ssh/id_rsa.pub`. See [Accessing VMs](modules/libvirt/README.md#accessing-vms) for details.

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

## Q: how can I change to another workspace?

If you want to work with more than one `main.tf` file, for example to use both a libvirt and an AWS configuration, you can follow [instructions in the README_ADVANCED.md file](README_ADVANCED.md#working-on-multiple-configuration-sets-workspaces-locally) to set up multiple workspaces.

To change to another workspace just remove and create the corresponding links again, and then execute `terraform init`.

## Q: Why do I get "is not a valid parameter" when I change between workspaces?

When we change between workspaces,it may happen that `terraform init` throws "is not a valid parameter" errors, as if we actually didn't change to another workspace. To resolve this just remove the terraform cache:

```
rm -r .terraform/
```
