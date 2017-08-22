# Advanced `main.tf` configurations

## Changing product versions

Some modules have a ``version`` variable that determines the software version. Specifically:
 * in `suse_manager`, `suse_manager_proxy` etc. `version` determines the SUSE Manager product version,
 * in `minion`, `client`, etc. `version` determines the SUSE Manager Tools version.

Legal values for released software are:
 * `2.1-released` (latest released Maintenance Update for SUSE Manager 2.1 and Tools)
 * `3.0-released` (latest released Maintenance Update for SUSE Manager 3.0 and Tools)
 * `3.1-released` (latest released alpha/beta/gold master candidate for SUSE Manager 3.1 and Tools)

Legal values for work-in-progress software are:
 * `2.1-nightly` (corresponds to the Build Service project Devel:Galaxy:Manager:2.1)
 * `3.0-nightly` (corresponds to the Build Service project Devel:Galaxy:Manager:3.0)
 * `3.1-nightly` (corresponds to the Build Service project Devel:Galaxy:Manager:3.1)
 * `head` (corresponds to the Build Service project Devel:Galaxy:Manager:Head)
 * `test` (corresponds to the Build Service project Devel:Galaxy:Manager:TEST)

Note: the version of Salt on minions is determined by this value, as Salt is obtained from SUSE Manager Tools repos.

Note: on clients and minions only, the version number can be omitted to take the default for the distribution, eg. `released` and `nightly` are legal values.

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

module "suma31pg" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "suma31pg"
  version = "3.1-released"
}
```

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
You can specifiy a base OS for `suse_manager` modules by specifying an `image` variable. There is a default selection if nothing is specified. Currently this only applies to versions `3.0` and up that can switch between `sles12sp1` and `sles12sp2`.

The following example creates a SUSE Manager server using "nightly" packages from version 3 based on SLES 12 SP2:

```hcl
module "suma3pg" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  image = "sles12sp2"
  name = "suma3pg"
  version = "3.0-nightly"
}
```

## Proxies

A `proxy` module is similar to a `client` module but has a `version` and a `server` variable pointing to the upstream server. You can then point clients to the proxy, as in the example below:

```hcl
module "suma3pg" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "suma3pg"
  version = "3.0-nightly"
}

module "proxy" {
  source = "./modules/libvirt/suse_manager_proxy"
  base_configuration = "${module.base.configuration}"

  name = "proxy"
  version = "3.0-nightly"
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
  version = "2.1-released"
  iss_slave = "suma21pgs.tf.local"
}

module "suma21pgs" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "suma21pgs"
  version = "2.1-released"
  iss_master = "${module.suma21pgm.configuration["hostname"]}"
}
```

Please note that `iss_master` is set from `suma21pgm`'s module output variable `hostname`, while `iss_slave` is simply hardcoded. This is needed for Terraform to resolve dependencies correctly, as dependency cycles are not permitted.

## Cucumber testsuite

It is possible to run [the Cucumber testsuite for SUSE Manager](https://github.com/SUSE/spacewalk-testsuite-base/) by using the main.tf.libvirt-testsuite.example file. This will create a test server, client and minion instances, plus a coordination node called a `controller` which runs the testsuite.

To start the testsuite, use:

```
ssh -t head-ctl.tf.local run-testsuite
```

To run individual Cucumber features, use:
```
ssh -t head-ctl.tf.local cucumber spacewalk-testsuite-base/features/my_feature.feature
```

Get HTML results with:
```
scp head-ctl.tf.local://root/spacewalk-testsuite-base/output.html .
```

You can configure a `mirror` host for the testsuite and that will be beneficial deploy performance, but presently an Internet connection will still be needed to deploy test hosts correctly.

You can also select [a specific branch of the Cucumber testsuite git repo](https://github.com/SUSE/spacewalk-testsuite-base/blob/master/docs/branches.md) via the `branch` variable in the `controller` module (by default an automatic selection is made).

## pgpool-II replicated database

Experimental support for a pgpool-II setup is included. You must configure two Postgres instances with fixed names `pg1.tf.local` and `pg2.tf.local` as per the definition below:

```hcl
module "suma3pg" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "suma3pg"
  version = "3.0-nightly"
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

## `minionswarm` hosts

It is possible to create large numbers of simulated minions using Salt's [minionswarm test script](https://docs.saltstack.com/en/latest/topics/releases/0.9.9.html#minionswarm).

A libvirt example follows:

```
module "minionswarm" {
  source = "./modules/libvirt/minionswarm"
  base_configuration = "${module.base.configuration}"

  name = "ms"
  count = 2
  server_configuration = "${module.suma3pg.configuration}"
}
```

This will create 400 minions on 2 swarm hosts. Currently only SLES 12 SP1 with the released Salt version are supported.

## SMT

You can configure SUSE Manager instances to download packages from an SMT server instead of SCC, in case a `mirror` is not used:

```hcl
module "suma3pg" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "suma3pg"
  version = "3.0-nightly"
  smt = "http://smt.suse.de"
}
```

## Add custom repos and packages

You can specify custom repos and packages to be installed at deploy time for a specific host:

```hcl
module "minsles12sp1" {
  source = "./modules/libvirt/minion"
  base_configuration = "${module.base.configuration}"

  name = "minsles12sp1"
  image = "sles12sp1"
  server_configuration = "${module.suma3pg.configuration}"

  additional_repos {
    tools = "http://download.opensuse.org/repositories/home:/SilvioMoioli:/tools/SLE_12_SP2/"
    virtualization_containers = "http://download.opensuse.org/repositories/Virtualization:/containers/SLE_12_SP2/"
  }

  additional_packages = [
    "terraform",
    "htop"
  ]
}
```

## Add custom repo GPG keys

If you need extra GPG keys to be installed for package installation, you can add them via the `gpg_keys` list variable to a module.
The list contains paths relative to the `salt/` directory, as in the following example:

```hcl
module "minssh-sles12sp2" {
  source = "./modules/libvirt/host"
  base_configuration = "${module.base.configuration}"
  name = "minssh-sles12sp2"
  image = "sles12sp2"
  gpg_keys = ["default/gpg_keys/galaxy.key"]
}
```

## Prometheus/Grafana monitoring

It is possible to install Prometheus exporters on a SUSE Manager Server instance via the `monitored` flag. Those can be consumed by Prometheus and Grafana server to analyze visually. A libvirt example follows:


```hcl
module "suma31pg" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "suma31pg"
  version = "head"
  monitored = true
}

module "grafana" {
  source = "./modules/libvirt/grafana"
  base_configuration = "${module.base.configuration}"
  server_configuration = "${module.suma31pg.configuration}"
}
```

Grafana is accessible at http://grafana.tf.local with username and password `admin`.

## Log forwarding

SUSE Manager Server modules support forwarding logs to log servers via the `log_server` variable. A libvirt example follows:

```hcl
module "suma31pg" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "suma31pg"
  version = "3.1-released"
  log_server = "logstash.mgr.suse.de:5045"
}
```

This will forward SUSE Manager Server logs to `logstash.mgr.suse.de` on port `5045`.

Setting this variable installs the `filebeat` package. [Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/index.html) is a log forwarder, pushing local log files to either [Logstash](https://www.elastic.co/products/logstash) or [Elasticsearch](https://www.elastic.co/products/elasticsearch).

The logstash input plugin for filebeat usually listens on port 5045. With the right configuration this gives you fully parsed logs for analysis ([an example is available here](https://github.com/kkaempf/logstash-tester/tree/openSUSE/spacewalk/config)).

Elasticsearch listens on port 9200 and provides full text search on logs.


## Evil Minions load generator

You can deploy an [evil-minions](https://github.com/moio/evil-minions) host in order to test load performance in your SUSE Manager server. A libvirt example would be:

```hcl
module "evil-minions" {
  source = "./modules/libvirt/evil_minions"
  base_configuration = "${module.base.configuration}"

  name = "evil-minions"
  server_configuration = "${module.suma31pg.configuration}"
  // see modules/libvirt/evil_minions/variables.tf for possible values
}
```

## Use SUSE Linux Enterprise unreleased (Test) packages

It is possible to run SUSE Manager servers, proxies, clients and minions with the latest packages currently in QAM, that is, upcoming updates. This is useful to spot regressions early, and can be activated via the `use_unreleased_updates` flag. Libvirt example:

```hcl
module "sumaheadpg" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "sumaheadpg"
  version = "head"
  use_unreleased_updates = true
}
```

## E-mail configuration

With the default configuration, whenever SUSE Manager server hosts are configured to use root@`hostname -d` as the email sender. The recipient's SMTP server may discard those emails since they come from a non-existent domain name.

This setting can be overridden with a custom 'from' address by supplying the parameter: `from_email`. A libvirt example would be:

```
module "suma3pg" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "suma3pg"
  version = "head"

  from_email = "root@mbologna.openvpn.suse.de"
}
```

Internal Server Errors and relative stacktraces are sent via e-mail by default to `galaxy-noise@suse.de`.
By suppling the parameter `traceback_email` you can override that address to have them in your inbox:

```
module "sumamail3" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "sumamail3"
  version = "head"

  traceback_email = "michele.bologna@chameleon-mail.com"
}
```
