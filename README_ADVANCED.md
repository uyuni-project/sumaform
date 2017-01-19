# Advanced `main.tf` configurations

## Multiple VMs of the same type

Some modules, for example clients and minions, support a `count` variable that allows you to create several instances at once. For example:

```hcl
module "minionsles12sp1" {
  source = "./modules/libvirt/minion"
  base_configuration = "${module.base.configuration}"

  name = "minionsles12sp1"
  image = "sles12sp1"
  server_configuration = "${module.suma3pg.configuration}"
  count = 10
}
```

This will create 10 minions connected to the `suma3pg` server.

## Change the base OS for supported SUSE Manager versions
You can specifiy a base OS for `suse_manager` modules by specifying an `image` variable. There is a default selection if nothing is specified. Currently this only applies to versions `3-stable` and `3-nightly` that can switch between `sles12sp1` and `sles12sp2`.

The following example creates a SUSE Manager server using "nightly" packages from version 3 based on SLES 12 SP2:

```hcl
module "suma3pg" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"
  
  image = "sles12sp2" 
  name = "suma3pg"
  version = "3-nightly"
} 
```

## Proxies

A `proxy` module is similar to a `client` module but has a `version` and a `server` variable pointing to the upstream server. You can then point clients to the proxy, as in the example below:

```hcl
module "suma3pg" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "suma3pg"
  version = "3-nightly"
}

module "proxy" {
  source = "./modules/libvirt/suse_manager_proxy"
  base_configuration = "${module.base.configuration}"

  name = "proxy"
  version = "3-nightly"
  server_configuration = "${module.suma3pg.configuration}"
}

module "clisles12sp1" {
  source = "./modules/libvirt/client"
  base_configuration = "${module.base.configuration}"

  name = "clisles12sp1"
  image = "sles12sp1"
  server_configuration = "${module.proxy.configuration}"
  count = 3
}
```

Note that proxy chains (proxies of proxies) also work as expected. You can find a list of customizable variables for the `suse_manager_proxy` module in `modules/libvirt/suse_manager_proxy/variables.tf`.

## Inter-Server Sync (ISS)

Create two SUSE Manager server modules and add `iss_master` and `iss_slave` variable definitions to them, as in the example below:

```hcl
module "suma21pgm" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "suma21pgm"
  version = "2.1-stable"
  iss_slave = "suma21pgs.tf.local"
}

module "suma21pgs" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "suma21pgs"
  version = "2.1-stable"
  iss_master = "${module.suma21pgm.configuration["hostname"]}"
}
```

Please note that `iss_master` is set from `suma21pgm`'s module output variable `hostname`, while `iss_slave` is simply hardcoded. This is needed for Trraform to resolve dependencies correctly, as dependency cycles are not permitted.

## Cucumber testsuite

It is possible to run [the Cucumber testsuite for SUSE Manager](https://github.com/SUSE/spacewalk-testsuite-base/) by using the main.tf.libvirt-testsuite.example file. This will create a test server, client and minion instances, plus a coordination node called a `control-node` which runs the testsuite.

You can select a branch of the Cucumber testsuite git repo via the `branch` variable in the control-node, default is `manager30` for the SUSE Manager 3.0 testsuite.

To start the testsuite, use:

```
ssh -t root@control-node.tf.local run-testsuite
```

Get HTML results with:
```
scp root@control-node.tf.local://root/spacewalk-testsuite-base/output.html .
```

You can configure a `package-mirror` host for the testsuite and that will be beneficial deploy performance, but presently an Internet connection will still be needed to deploy test hosts correctly.

## pgpool-II replicated database

Experimental support for a pgpool-II setup is included. You must configure two Postgres instances with fixed names `pg1.tf.local` and `pg2.tf.local` as per the definition below: 

```hcl
module "suma3pg" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "suma3pg"
  version = "3-nightly"
  database = "pgpool"
}

module "pg1" {
  source = "./modules/libvirt/postgres"
  base_configuration = "${module.base.configuration}"
  name = "pg1"
}

module "pg2" {
  source = "./modules/libvirt/postgres"
  base_configuration = "${module.base.configuration}"
  name = "pg2"
}
```

## Plain hosts

You can have totally unconfigured hosts in your configuration by using the `host` module, for example if you need to test bootstrapping.

A libvirt example follows:

```hcl
module "vanilla" {
  source = "./modules/libvirt/host"
  base_configuration = "${module.base.configuration}"

  name = "vanilla"
  image = "sles12sp1"
}
```

## Change Salt/SUSE Manager tools version in minion or client

By default minions will get the latest stable Salt version for their distro (for SLE systems this means the version shipping with the latest stable SUSE Manager Tools repo). You can use the `version` variable to override this and set a particular version of Salt - values taken are the same as the SUSE Manager versions (such as `3-nightly` or `head`). The version identified can be omitted to take the default for the distro, so `stable` and `nightly` are legal values too.

The same mechanism works for clients, in that case the SUSE Manager Tools versions change instead of Salt. For example, `version = "head"` will install SUSE Manager Tools from the upcoming SUSE Manager major release.

A libvirt example follows:

```hcl
module "minsles12sp1" {
  source = "./modules/libvirt/minion"
  base_configuration = "${module.base.configuration}"

  name = "minsles12sp1"
  image = "sles12sp1"
  server_configuration = "${module.proxy.configuration}"
  version = "nightly"
}
```
