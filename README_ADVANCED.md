# Advanced `main.tf` configurations

## Multiple VMs of the same type

Some modules, for example clients and minions, support a `count` variable that allows you to create several instances at once. For example:

```terraform
module "minionsles12sp1" {
  source = "./modules/libvirt/minion"

  name = "minionsles12sp1"
  image_id = "${module.sles12sp1.id}"
  server = "${module.suma3pg.hostname}"
  count = 10
}
```

This will create 10 minions connected to the `suma3pg` server.

## Proxies

A `proxy` module is similar to a `client` module but has a `version` and a `server` variable pointing to the upstream server. You can then point clients to the proxy, as in the example below:

```terraform
module "suma3pg" {
  source = "./modules/libvirt/suse_manager"
  cc_username = "UC7"
  cc_password = ...

  name = "suma3pg"
  image_id = "${module.sles12sp1.id}"
  version = "3-nightly"
}

module "proxy" {
  source = "./modules/libvirt/suse_manager_proxy"

  name = "proxy"
  image_id = "${module.sles12sp1.id}"
  version = "3-nightly"
  server = "${module.suma3pg.hostname}"
}

module "clisles12sp1" {
  source = "./modules/libvirt/client"

  name = "clisles12sp1"
  image_id = "${module.sles12sp1.id}"
  server = "${module.proxy.hostname}"
  count = 3
}
```

Note that proxy chains (proxies of proxies) also work as expected. You can find a list of customizable variables for the `suse_manager_proxy` module in `modules/libvirt/suse_manager_proxy/variables.tf`.

## Inter-Server Sync (ISS)

Create two SUSE Manager server modules and add `iss_master` and `iss_slave` variable definitions to them, as in the example below:

```terraform
module "suma21pgm" {
  source = "./modules/libvirt/suse_manager"
  cc_username = "UC7"
  cc_password = ...

  name = "suma21pgm"
  image_id = "${module.sles11sp3.id}"
  version = "2.1-stable"
  iss_slave = "suma21pgs.tf.local"
}

module "suma21pgs" {
  source = "./modules/libvirt/suse_manager"
  cc_username = "UC7"
  cc_password = ...

  name = "suma21pgs"
  image_id = "${module.sles11sp3.id}"
  version = "2.1-stable"
  iss_master = "${module.suma21pgm.hostname}"
}
```

Please note that `iss_master` is set from `suma21pgm`'s module output variable `hostname`, while `iss_slave` is simply hardcoded. This is needed for Trraform to resolve dependencies correctly, as dependency cycles are not permitted.

## pgpool-II replicated database

Experimental support for a pgpool-II setup is included. You must configure two Postgres instances with fixed names `pg1.tf.local` and `pg2.tf.local` as per the definition below: 

```terraform
module "suma3pg" {
  source = "./modules/libvirt/suse_manager"
  cc_username = "UC7"
  cc_password = ...

  name = "suma3pg"
  image_id = "${module.sles12sp1.id}"
  version = "3-nightly"
  database = "pgpool"
}

module "pg1" {
  source = "./modules/libvirt/postgres"
  name = "pg1"
  image_id = "${module.sles12sp1.id}"
}

module "pg2" {
  source = "./modules/libvirt/postgres"
  name = "pg2"
  image_id = "${module.sles12sp1.id}"
}
```
