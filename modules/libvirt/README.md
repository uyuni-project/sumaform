# libvirt-specific configuration

## First-time configuration

 - copy `main.tf.libvirt.example` to `main.tf`
 - if your VMs are to be deployed on an external libvirt host:
   - change the libvirt connection URI in the `provider` section. Typically it has the form `qemu+ssh://<USER>@<HOST>/system` assuming that `<USER>` has passwordless SSH access to `<HOST>`
   - set up bridged networking:
     - ensure your target libvirt host has a bridge device on the network you want to expose your machines on ([openSUSE instructions](https://doc.opensuse.org/documentation/leap/virtualization/html/book.virt/cha.libvirt.networks.html#libvirt.networks.bridged) [Ubuntu instructions](https://help.ubuntu.com/community/NetworkConnectionBridge))
     - uncomment the `bridge` variable declaration in the `base` module and add proper device name (eg. `br1`)
     - change the `network_name` variable declaration to empty string (`""`)
     - optionally specify fixed MAC addresses by adding `mac = "CA:FE:BA:BE:00:01"` lines to VM modules
   - if other sumaform users deploy to the same host, or different bridged hosts in the same network, uncomment the `name_prefix` variable declaration in the `base` module to specify a unique prefix for your VMs
 - complete the `cc_password` variable in the `base` module
 - make sure that:
   - either your target libvirt host has a storage pool named `default`
   - or you [create one](https://www.suse.com/documentation/sles-12/singlehtml/book_virt/book_virt.html#sec.libvirt.storage.vmm.addpool)
   - or you specify a different name by uncommenting the `pool` variable declaration in the `base` module
 - if you are not using bridged networking, make sure that:
   - either your target libvirt host has a NAT network which is named `default`
   - or you [create one](https://wiki.libvirt.org/page/TaskNATSetupVirtManager)
   - or you specify a different name by uncommenting the `network_name` variable declaration in the `base` module
 - decide the set of virtual machines you want to run. Delete any `module` section relative to VMs you don't want to use and feel free to copy and paste to add more
 - run `terraform init` to make sure Terraform has detected all modules
 - run `terraform apply` to actually have the VMs set up!

## Accessing VMs

All machines come with user `root` with password `linux`. They are also accessible via your SSH public key (by default `~/.ssh/id_rsa.pub`) if you have one.

By default, the machines use Avahi (mDNS), and are configured on the `.tf.local` domain. Thus if your host is on the same network segment of the virtual machines you can simply use:

```
ssh root@suma32pg.tf.local
```

If you use Avahi and are on another network segment, you can only connect using an IP address, because mDNS packets do not cross network boundaries unless using reflectors.

If you want to use a different SSH key, please check the README_ADVANCED.md file, in section "Custom SSH keys".
If you don't want to use mDNS, or want to forward Avahi between networks, please check that same file, in section "Disabling Avahi and Avahi reflectors".
If mDNS does not work out of the box, please check TROUBLESHOOTING.md file, under question "How can I work around name resolution problems with `tf.local` mDNS/Zeroconf/Bonjour/Avahi names?".

Web access is on standard ports, so `firefox suma3pg.tf.local` will work as expected. SUSE Manager default user is `admin` with password `admin`.

Finally, the images come with serial console support, so you can use

```
virsh console suma32pg
```
especially in the case the network is not working and you need to debug it, or if the images have difficulties booting.


## Mirror

If you are using `sumaform` outside of the SUSE Nuremberg network you should use a special extra virtual machine named `mirror` that will cache packages downloaded from the SUSE engineering network for faster access and lower bandwidth consumption.

It will be be used exclusively by other VMs to download SUSE content - that means your SUSE Manager servers, clients, minions and proxies will be "fully disconnected", not requiring Internet access to operate.

To enable `mirror`, add `mirror = "mirror.tf.local"` to the `base` section in `main.tf` and add the following mode definition:
```hcl
module "mirror" {
  source = "./modules/libvirt/mirror"
  base_configuration = "${module.base.configuration}"

  data_pool = "data"
}
```

Note you are encouraged to specify an additional libvirt storage pool name (`data` in the example above). Downloaded content will be placed on a separate disk in this pool - it helps SUSE Manager performance significantly if the pool is mapped onto a different physical disk. You can configure a pool with `virt-manager` like in the following image:

![data pool configuration in virt-manager](/help/data-pool-configuration.png)

Omitting the `data_pool` variable results in the default "default" storage pool being used.

Note that `mirror` must be populated before any host can be deployed - by default its cache is refreshed nightly via `cron`, you can also schedule a one-time refresh via the `/root/mirror.sh` script.

## Customize virtual hardware

You can add the following parameters to a `modules/libvirt/host` module in `main.tf` to customize its virtual hardware:
 - `memory = <N>` to set the machine's RAM to N MiB
 - `vcpu = <N>` to set the number of virtual CPUs

## Keep a VM turned off

You can add `running = false` to any libvirt host to keep it turned off. This is useful if you want to keep the instance around (ie. not [destroying](https://www.terraform.io/intro/getting-started/destroy.html) it) but not to consume resources.

## Only upload a subset of available images

By default all known base OS images are uploaded to the libvirt host (currently several versions of SLES and CentOS). It is possible to limit the OS selection in order to avoid wasting space and bandwidth, if the needed OSs are known a priori.

In order to do that use the `images` variable in the `base` module, like in the following example:

```hcl
module "base" {
  source = "./modules/libvirt/base"

  ...
  images = ["centos7", "sles12sp2"]
}
```

The list of all supported images is available in "modules/libvirt/base/variables.tf".

## Virtual hosts

Virtualization hosts are Salt minions that are also capable to run virtual machines using the KVM hypervisor.
As this mechanism relies on nested virtualization, Xen is not supported.

An example follows:

```hcl
module "virthost" {
  source = "./modules/libvirt/virthost"
  base_configuration = "${module.base.configuration}"
  server_configuration = "${module.srv.configuration}"
  ...
  name = "min-kvm"
  image = "sles15sp1"
  ...
  vcpu = 3
  memory = 2048
}
```

The created virtual host will get the same CPU model its host has.
This means that in order for virtual hosts to host virtual machines, nested virtualization has to be enabled on the physical machine.
For this, the `kvm_intel` or `kvm_amd` kernel modules need to have `nested` parameter set to `1`.
To check if nested virtualization is enabled on the physical machine, the following command needs to return either `1` or `Y`:

```
# For intel CPU:
cat /sys/module/kvm_intel/parameters/nested

# For AMD CPU:
cat /sys/module/kvm_amd/parameters/nested
```

The generated virtual host will be setup with:

* a `default` virtual network or `nat` type with `192.168.42.1/24` IP addresses,
* a `default` virtual storage pool of `dir` type targeting `/var/lib/libvirt/images`
* and a VM template disk image located in `/var/testsuite-data/disk-image-template.qcow2`.

The template disk image is the `opensuse423` image used by sumaform and is downloaded when applying the highstate on the virtual host.
In order to use another or a cached image, use the `hvm_disk_image` variable.
For example, to use a local image copy it in `salt/virthost/` folder and set `hvm_disk_image = "salt://virthost/imagename.qcow2"`
