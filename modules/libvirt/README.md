# libvirt-specific configuration

## First-time configuration

 - copy `main.tf.libvirt.example` to `main.tf`
 - if your VMs are to be deployed on an external libvirt host:
   - change the libvirt connection URI in the `provider` section. Typically it has the form `qemu+ssh://<USER>@<HOST>/system` assuming that `<USER>` has passwordless SSH access to `<HOST>`
   - ensure your target libvirt host has a bridge device on the network you want to expose your machines on ([Ubuntu instructions](https://help.ubuntu.com/community/NetworkConnectionBridge))
   - add the `bridge = "<DEVICE_NAME>"` variable to all VM modules, eg:
   ```terraform
   module "suma3pg" {
     source = "./modules/libvirt/suse_manager"
     ...
     bridge = "br0"
   }
   ```
   - you can specify an optional MAC address by adding a `mac = "CA:FE:BA:BE:00:01"` variable to VM modules
   - if other sumaform users deploy to the same host, add the `name_prefix` variable to all modules (VMs, images, networks) with a unique string (for example, your username) to avoid clashes, eg:
   ```terraform
   module "sles12sp1" {
     source = "./modules/libvirt/images/sles12sp1"
     ...
     name_prefix = "moio"
   }
 - if your target libvirt host storage pool is not named "default":
   - add `pool = "mypoolname"` to any image and VM module that has to be created in that pool, eg:
   ```terraform
   module "sles12sp1" {
     source = "./modules/libvirt/images/sles12sp1"
     ...
     pool = "mypoolname"
   }
   ...
   module "suma3pg" {
     source = "./modules/libvirt/suse_manager"
     ...
     pool = "mypoolname"
   }
   ```
 - decide the set of virtual machines you want to run. Delete any `module` section relative to images or VMs you don't want to use and feel free to copypaste to add more
 - complete any missing `cc_password` variables
 - run `terraform plan` to see what Terraform is about to do
 - run `terraform apply` to actually have the VMs set up!

## Accessing VMs

All machines come with avahi's mDNS configured by default on the `.tf.local` domain, and a `root` user with password `linux`. Provided your host is on the same network segment of the virtual machines you can access them via:

```
ssh root@moio-suma3pg.tf.local
```

You can add the following lines to `~/.ssh/config` to avoid checking hosts and specifying a username:

```
Host *.tf.local
StrictHostKeyChecking no
UserKnownHostsFile=/dev/null
User root
```

Web access is on standard ports, so `firefox suma3pg.tf.local` will work as expected. SUSE Manager default user is `admin` with password `admin`.

## package-mirror

If you are using `sumaform` outside of the SUSE network you can choose to add a special extra virtual machine named `package-mirror` that will cache packages downloaded from the SUSE engineering network (by default every night, or manually by executing `/root/mirror.sh`).

It will be be used exclusively by other VMs to download SUSE content - that means your setup will be "fully disconnected", not requiring Internet access to operate.

To enable `package-mirror`, add the following modules in `main.tf`:
```terraform
module "opensuse421" {
  source = "./modules/libvirt/images/opensuse421"
}

module "package_mirror" {
  source = "./modules/libvirt/package_mirror"
  cc_username = "UC7"
  cc_password = // add password here
  image_id = "${module.opensuse421.id}"
  data_pool = "data"
}
```

Note you are encouraged to specify a separate `data` storage pool for this host to store downloaded content. It helps SUSE Manager performance significantly to define such pool on a separate disk. You can configure it with `virt-manager` like in the following image:

![data pool configuration in virt-manager](/help/data-pool-configuration.png)

Omitting the `data_pool` results in the default "default" storage pool being used.

Once the package-mirror is defined, created and populated you can configure any VM to use it with an extra `package_mirror` variable, eg:
```terraform
module "suma3pg" {
  source = "./modules/libvirt/suse_manager"
  ...
  package_mirror = "${module.package_mirror.hostname}"
}
```

## Customize virtual hardware

You can add the following parameters to a `modules/libvirt/host` module in `main.tf` to customize its virtual hardware:
 - `memory = <N>` to set the machine's RAM to N MiB
 - `vcpu = <N>` to set the number of virtual CPUs

## Keep a VM turned off

You can add `running = false` to any libvirt host to keep it turned off. This is useful if you want to keep the instance around (ie. not [destroying](https://www.terraform.io/intro/getting-started/destroy.html) it) but not to consume resources.
