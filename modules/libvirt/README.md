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
   - change the `name` variable so that it does not collide with machines from other users. For example, add your username as a prefix
 - if your target libvirt host storage pool is not named "default":
   - add `pool = "mypoolname"` to the `images` module and to any VM module that has to be created in that pool, eg:
```terraform
module "suma3pg" {
  source = "./modules/libvirt/suse_manager"
  ...
  pool = "mypoolname"
}
```
 - upload base OS images to the libvirt host:
```
terraform get
terraform apply -target=module.network -target=module.images
```
 - decide the set of virtual machines you want to run. Delete any `module` section relative to VMs you don't want to use and feel free to copypaste to add more
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

If you are using `sumaform` outside of the SUSE network you can choose to add a special extra virtual machine named `package-mirror` that will cache packaged downloaded from the SUSE engineering network (by default every night, or manually by executing `/root/mirror.sh`).

If you configure it, it will be be used exclusively by other VMs to download SUSE content - that means your setup will be "fully disconnected", not requiring Internet access to operate.

To enable `package-mirror`, uncomment its section in `main.tf` and the `package_mirror` variable in all VM sections.

Note that `package-mirror` needs access the SUSE engineering network (or VPN) at package download time.

Also note that, by default, it requires a different `libvirt` storage pool, because typically we want packages to be stored in a separate disk. By default the pool name is `data` and you can configure it with `virt-manager` like so:

![data pool configuration in virt-manager](/help/data-pool-configuration.png)

You can also override this setting and keep packages in the same pool as the base images and disks by changing the `data_pool` parameter to `default`.


## Customize virtual hardware

You can add the following parameters to a `modules/libvirt/host` module in `main.tf` to customize its virtual hardware:
 - `memory = <N>` to set the machine's RAM to N MiB
 - `vcpu = <N>` to set the number of virtual CPUs

## Keep a VM turned off

You can add `running = false` to any libvirt host to keep it turned off. This is useful if you want to keep the instance around (ie. not [destroying](https://www.terraform.io/intro/getting-started/destroy.html) it) but not to consume resources.

## Update base OS images

Taint the VM disk(s) you want to update and re-apply the plan:
```
terraform taint -module=images libvirt_volume.sles12sp1
terraform apply
```
