# Troubleshooting

## Q: how can I work around backend not defined error?

Typical error message follows:

```bash
Error: Unreadable module directory

Unable to evaluate directory symlink: lstat modules/backend: no such file or directory
```

Terraform cannot find the path for the backend in use.
Create a symbolic link to the backend module directory inside the `modules` directory:

```bash
cd modules
ln -sfn ../backend_modules/<BACKEND> backend
```

## Q: how can I work around name resolution problems with `tf.local` mDNS/Zeroconf/Bonjour/Avahi names?

Typical error message follows:

```bash
Could not resolve hostname server.tf.local: Name or service not known

# or

connect: Invalid argument
```

Check that:

- your firewall is not blocking UDP port 5353
  - on SUSE systems check YaST -> Security and Users -> Firewall -> Zones -> "public" and "libvirt"
  - "mdns" should appear on the list on the right (allowed)
- Avahi is installed and running
  - typically you can check this via systemd: `systemctl status avahi-daemon`
  - be sure you don't have mixed versions: `rpm -qa | grep avahi`
- Avahi is capable of resolving the host you are trying to reach: `avahi-resolve -n <host>.tf.local`
- mdns is configured in glibc's Name Server Switch configuration file

In `/etc/nsswitch.conf` you should see a `hosts:` line that looks like the following:

```config
hosts:          files mdns4 [NOTFOUND=return] dns
```

`mdns4` should be present in this line. If it is not, add it.

Note: `mdns6` also exists to resolve to IPv6 addresses, but currently [one known issue exists](https://github.com/lathiat/avahi/issues/110) where it may return incorrect addresses (specifically: link local addresses starting with `fe80:` but without a zone identifier trailer such as `%eth0`). We recommend IPv4 for the time being.

Starting with `nss-mdns` version 0.14.1, you also need to populate `/etc/mdns.allow` with:

```bash
.local
.tf.local
```

`mdns.allow` is required to [force all multicast DNS domains to be resolved regardless of label count or unicast SOA records](https://github.com/lathiat/nss-mdns/blob/master/README.md#etcmdnsallow).

## Q: how can I work around slowness in resolution of `tf.local` mDNS/Zeroconf/Bonjour/Avahi names?

If there is a 5-second delay on any name resolution (or ping) between Avahi hosts, a likely cause is that ipv6 is enabled on the VMs (that is the default setting) but the network is blocking ipv6 traffic.

This can happen, for example, in libvirt if the NAT network being used does not have ipv6 enabled. Re-creating the network with ipv6 enabled fixes the problem.

## Q: how can I work around a libvirt permission denied error?

Typical error message follows:

```bash
libvirt_domain.domain: Error creating libvirt domain: [Code-1] [Domain-10]
internal error: process exited while connecting to monitor:
2016-10-14T06:49:07.518689Z qemu-system-x86_64: -drive file=/var/lib/libvirt/images/mirror-main-disk,format=qcow2,if=none,id=drive-virtio-disk0:
Could not open '/var/lib/libvirt/images/mirror-main-disk':
Permission denied

# Another possible one is:
libvirt_domain.domain: Error creating libvirt domain: virError(Code=1, Domain=0, Message='internal error: child reported: Kernel does not provide mount namespace: Permission denied')

# Yet another one is:
Failed to connect socket to '/var/run/libvirt/libvirt-sock': No such file or directory'
```

Some variants of this issue will also be logged in `/var/log/syslog` like:

```bash
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

- host-guest protection: add `security_driver = "none"` to `/etc/libvirt/qemu.conf
- guest-guest protection:

```bash
sudo ln -s /etc/apparmor.d/usr.sbin.libvirtd /etc/apparmor.d/disable/
sudo /etc/init.d/apparmor restart
sudo aa-status | grep libvirt # output should be empty
```

## Q: how can I workaround a "dial tcp" error?

If you run into this error:

`dial tcp 192.168.122.193:22: getsockopt: network is unreachable`

during the `terraform apply`, it means Terraform was able to create a VM, but then is unable to log in via SSH do configure it. This is typically caused by network misconfiguration - `ping 192.168.122.193` should work but it does not. Please double check your networking configuration. If you are using AWS, make sure your current IP is listed in the `ssh_allowed_ips` variable (or check it is whitelisted in AWS Console -> VPC -> Security Groups).

## Q: how do I re-apply the Salt state that was used to provision the machine?

Run `sh /root/salt/highstate.sh`.

## Q: how to force the re-creation of a resource?

A: you can use [Terraform's taint command](https://www.terraform.io/docs/commands/taint.html) to mark a resource to be re-created during the next `terraform apply`. To get the correct name of the module and resource use `terraform state list`:

```bash
$ terraform state list
...
module.server.module.server.libvirt_volume.main_disk[0]

$ terraform taint module.server.module.server.libvirt_volume.main_disk[0]
Resource instance module.server.module.server.libvirt_volume.main_disk[0] has been marked as tainted.
```

## Q: how to force the re-download of an image?

A: see above, use the taint command as per the following example:

```bash
$ terraform state list
...
module.base.libvirt_volume.volumes[2]

$ terraform taint module.base.libvirt_volume.volumes[2]
Resource instance module.base.libvirt_volume.volumes[2] has been marked as tainted.
```

Please note that any dependent volume and module should be tainted as well before applying (eg. if you are tainting the `sles12sp5` image, make sure you either have no VMs based on that OS or that they are all tainted).

## Q: I get the error "* file: open /home/<user>/.ssh/id_rsa.pub: no such file or directory in:"

Terraform cannot find your SSH key in the default path `~/.ssh/id_rsa.pub`. See [Accessing VMs](backend_modules/libvirt/README.md#accessing-vms) for details.

## Q: how can I workaround an "libvirt_domain.domain: diffs didn't match during apply" libvirt error?

If you have just switched from non-bridged to bridged networking or vice versa you might get the following error:

```bash
Error applying plan:

1 error(s) occurred:

libvirt_domain.domain: diffs didn't match during apply. This is a bug with Terraform and should be reported as a GitHub Issue.
...
Mismatch reason: attribute mismatch: network_interface.0.bridge
```

This is a known issue, simply repeat the `terraform apply` command and it will go away.

## Q: how do I workaround a "stat salt: no such file or directory" when applying the plan?

If you run `terraform apply` from outside of the sumaform tree, you will get the error message:

```bash
Error applying plan:

1 error(s) occurred:

stat salt: no such file or directory
```

A simple solution is to create a symbolic link pointing to the `salt` directory on top level of the sumaform files tree. Create this symlink in your current directory.

## Q: how can I change to another workspace?

If you want to work with more than one `main.tf` file, for example to use both a libvirt and an AWS configuration, you can follow [instructions in the README_ADVANCED.md file](README_ADVANCED.md#working-on-multiple-configuration-sets-workspaces-locally) to set up multiple workspaces.

To change to another workspace just remove and create the corresponding links again, and then execute `terraform init`.

## Q: Why do I get "is not a valid parameter" when I change between workspaces?

When we change between workspaces,it may happen that `terraform init` throws "is not a valid parameter" errors, as if we actually didn't change to another workspace. To resolve this just remove the terraform cache:

```bash
rm -r .terraform/
```

## Q: Why are documentation files not installed after package installation?

Sumaform uses JeOS and, by default, `zypper` is configured to not install docs.
To change that behavior, edit `/etc/zypp/zypp.conf` and change the property `rpm.install.excludedocs = no`
and re-install the package.

## Q: How do I workaround a "doesn't match any of the checksums previously recorded in the dependency lock file" error?

This error can occur during a `terraform init` execution:

```bash
$ terraform init
Initializing modules...

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of dmacvicar/libvirt from the dependency lock file
- Reusing previous version of hashicorp/null from the dependency lock file
- Reusing previous version of hashicorp/template from the dependency lock file
- Using previously-installed hashicorp/template v2.2.0
- Installing dmacvicar/libvirt v0.6.3...
- Using previously-installed hashicorp/null v3.1.0
╷
│ Error: Failed to install provider
│ 
│ Error while installing dmacvicar/libvirt v0.6.3: the local package for registry.terraform.io/dmacvicar/libvirt 0.6.3 doesn't match any of the checksums previously recorded in the dependency lock file (this might be because the available checksums are for packages
│ targeting different platforms)
```

Just delete the `.terraform.lock.hcl` file inside your sumaform folder and do another `terraform init` after that:

```bash
rm .terraform.lock.hcl
terraform init
```

## Q: How do I workaround the "The provider dmacvicar/libvirt does not support resource type "libvirt_combustion" error".

At the time of writing, the upstream `dmacvicar/libvirt` terraform provider does not support combustion. However, a [pull request](https://github.com/dmacvicar/terraform-provider-libvirt/pull/1068) was created to resolve this issue and an RPM of `terraform-provider-libvirt` that supports combustion is created and now hosted on the [sumaform repository](https://download.opensuse.org/repositories/systemsmanagement:/sumaform).

1\. Add the sumaform repository

```
zypper ar -f https://download.opensuse.org/repositories/systemsmanagement:/sumaform/openSUSE_Leap_15.5 sumaform
```

Swap out `openSUSE_Leap_15.5` for `openSUSE_Leap_15.4` or `openSUSE_Tumbleweed` if you’re using a different version of openSUSE.

2\. Install `terraform-provider-libvirt` from sumaform

```
zypper in --repo sumaform terraform-provider-libvirt
```

3\. Edit your `.terraform.lock.hcl` and remove the following block:
```
 provider "registry.terraform.io/dmacvicar/libvirt" {
  ...
 }
```

4\. Finally, run `terraform init`

See the terraform [docs](https://www.terraform.io/language/files/dependency-lock) for more information on the dependency
lock file.
