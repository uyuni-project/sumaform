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
 - run `terraform get` to make sure Terraform has detected all modules
 - run `terraform plan` to see what Terraform is about to do
 - run `terraform apply` to actually have the VMs set up!

## Accessing VMs

All machines come with avahi's mDNS configured by default on the `.tf.local` domain, and user `root` with password `linux` accessible via your SSH public key (by default `~/.ssh/id_rsa.pub`).

Thus if your host is on the same network segment of the virtual machines you can simply use:
```
ssh root@moio-suma3pg.tf.local
```

If you want to use a different SSH key, or mDNS does not work out of the box, or if you don't want to use mDNS, please check the README_ADVANCED.md and TROUBLESHOOTING.md files.

Web access is on standard ports, so `firefox suma3pg.tf.local` will work as expected. SUSE Manager default user is `admin` with password `admin`.

Avahi can be disabled if it is not needed (bridged networking mode, all VMs with static MAC addresses and names known in advance). In that case use the following variables in the `base` module:
```hcl
use_avahi = false
domain = "mgr.suse.de"
```

## mirror

If you are using `sumaform` outside of the SUSE network you can choose to add a special extra virtual machine named `mirror` that will cache packages downloaded from the SUSE engineering network for faster access and lower bandwidth consumption.

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
