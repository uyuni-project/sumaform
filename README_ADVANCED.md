# Advanced `main.tf` configurations

## Changing product versions

Some modules have a ``version`` variable that determines the software version. Specifically:
 * in `suse_manager`, `suse_manager_proxy` etc. `version` determines the SUSE Manager product version,
 * in `minion`, `client`, etc. `version` determines the SUSE Manager Tools version.

Legal values for released software are:
 * `3.0-released` (latest released Maintenance Update for SUSE Manager 3.0 and Tools)
 * `3.1-released` (latest released alpha/beta/gold master candidate for SUSE Manager 3.1 and Tools)

Legal values for work-in-progress software are:
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

## Turning convenience features off

By default, sumaform deploys hosts with a range of tweaked settings for convenience reasons. If in your use case this is not wanted, you can turn those off via the following variables.

 * `client` module:
   * `auto_register`: automatically registers clients to the SUSE Manager Server. Set to `false` for manual registration
 * `minion` module:
   * `auto_connect_to_master`: automatically connects to the Salt Master. Set to `false` to manually configure
 * `proxy` module:
   * `auto_register`: automatically registers the proxy to the SUSE Manager Server. Set to `false` for manual registration
   * `download_private_ssl_key`: automatically copies SSL certificates from the upstream SUSE Manager Server or SUSE Manager Proxy. Requires `publish_private_ssl_key` on the upstream server or proxy. Set to `false` for manual distribution
   * `auto_configure`: automatically runs the `confure-proxy.sh` script which enables Proxy functionality. Set to `false` to run manually. Requires `auto_register` and `download_private_ssl_key`
   * `generate_bootstrap_script`: generates a bootstrap script for traditional clients and copies it in /pub. Set to `false` to generate manually. Requires `auto_configure`
   * `publish_private_ssl_key`: copies the private SSL key in /pub for cascaded Proxies to copy automatically. Set to `false` for manual distribution. Requires `download_private_ssl_key`
 * `suse_manager_server` module:
   * `create_first_user`: whether to automatically create the first user (the SUSE Manager Admin)
     * `server_username` and `server_password`: define credentials for the first user, admin/admin by default
   * `disable_firewall`: disables the firewall making all ports available to any host. Set to `false` to only have typical SUSE Manager ports open
   * `allow_postgres_connections`: configure Postgres to accept connections from external hosts. Set to `false` to only allow localhost connections
   * `unsafe_postgres`: use PostgreSQL settings that improve performance by worsening durability. Set to `false` to ensure durability
   * `java_debugging`: enable Java debugging and profiling support in Tomcat and Taskomatic
   * `skip_changelog_import`: import RPMs without changelog data, this speeds up spacewalk-repo-sync. Set to `false` to import changelogs
   * `browser_side_less`: enable compilation of LESS files in the browser, useful for development. Set to `false` to disable
   * `mgr_sync_autologin`: whether to set mgr-sync credentials in the .mgr-sync file. Requires `create_first_user`
   * `create_sample_channel`: whether to create an empty test channel. Requires `create_first_user`
   * `create_sample_activation_key`: whether to create a sample activation key. Requires `create_first_user`
   * `create_sample_bootstrap_script`: whether to create a sample bootstrap script for traditional clients. Requires `create_sample_activation_key`
   * `publish_private_ssl_key`: copies the private SSL key in /pub for Proxies to copy automatically. Set to `false` for manual distribution

## Adding channels to SUSE Manager Servers

You can specifiy a set of SUSE official channels to be added at deploy time of a SUSE Manager Server. This operation is typically time-intensive, thus it is disabled by default. In order to add a channel, first get the label name from an existing SUSE Manager Server:

```
# mgr-sync list channels --compact
Available Channels:
...
[ ] sles12-sp2-pool-x86_64
```

Then add it to the `channels` variable in a SUSE Manager Server module:

```hcl
module "suma3pg" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "suma3pg"
  version = "3.1-nightly"
  channels = ["sles12-sp2-pool-x86_64"]
}
```

## Shared resources, prefixing, sharing virtual hardware

Whenever multiple sumaform users deploy to the same virtualization hardware (eg. libvirt host, OpenStack instance) it is recommended to set the `name_prefix` variable in the `base` module in order to have a unique per-user prefix for all resource names. This will prevent conflicting names.

Additionally, it is possible to have only one user to upload images and other shared infrastructure such as mirrors, having all other users re-use them. In order to accomplish this:
 * add a `use_shared_resources = true` variable to the `base` module of all users but one
 * make sure there is exactly one user that does not have the variable set, make sure this user has no `name_prefix` set. This user will deploy shared infrastructure for all users

## Custom SSH keys

If you want to use another key for all VMs, specify the path of the public key with `ssh_key_path` into the `base` config. Example:

```hcl
module "base" {
  [...]
  ssh_key_path = "~/.ssh/id_mbologna_terraform.pub"
  [...]
}
```

The `ssh_key_path` option can also be specified on a per-host basis. In this case, the key specified is treated as an additional key, copied to the machine as well as the `ssh_key_path` specified in the `base` section.

If you don't want to copy any ssh key at all (and use passwords instead), just supply an empty file (eg. `ssh_key_path = "/dev/null"`).

## SSH access without specifying a username

You can add the following lines to `~/.ssh/config` to avoid checking hosts and specifying a username:

```
Host *.tf.local
StrictHostKeyChecking no
UserKnownHostsFile=/dev/null
User root
```

## Activation Keys for minions

You can specify an Activation Key string for minions to use at onboarding time to a SUSE Manager Server. An example follows:

```hcl
module "min" {
  source = "./modules/libvirt/minion"
  base_configuration = "${module.base.configuration}"

  name = "min"
  image = "sles12sp2"
  server_configuration = "${module.suma3pg.configuration}"
  activation_key = "1-DEFAULT"
}
```

## Change the base OS for supported SUSE Manager versions

You can specifiy a base OS for `suse_manager` modules by specifying an `image` variable. There is a default selection if nothing is specified. Please note that not all SUSE Manager versions support all OSs, refer to official documentation to select a compatible OS. In particular, `opensuse423` can presently only be used for the `head` version.

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
module "master" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "master"
  version = "3.1-released"
  iss_slave = "suma3pgs.tf.local"
}

module "slave" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "slave"
  version = "3.1-released"
  iss_master = "${module.master.configuration["hostname"]}"
}
```

Please note that `iss_master` is set from `master`'s module output variable `hostname`, while `iss_slave` is simply hardcoded. This is needed for Terraform to resolve dependencies correctly, as dependency cycles are not permitted.

Also note that this requires `create_first_user` and `publish_private_ssl_key` settings to be true (they are by default).

## Cucumber testsuite

It is possible to run [the Cucumber testsuite for SUSE Manager](https://github.com/SUSE/spacewalk-testsuite-base/) by using the `main.tf.libvirt-testsuite.example` file. This will create a test server, client and minion instances, plus a coordination node called a `controller` which runs the testsuite.

The proxy, the SSH minion, and the CentOS minion are optional. The server, traditional client and normal minion are not.

To start the testsuite, use:

```
ssh -t head-ctl.tf.local run-testsuite
```

To run sets of Cucumber features, edit `run_sets/testsuite.yml` and then run `run-testsuite`. Keep in mind that:
 - features prefixed with `core_` are essential for others to work, cannot be repeated and must be executed in the order given by `testsuite.yml`
 - featurs not prefixed with `core_` are idempotent, so they can be run multiple times without changing test results.

Once all `core_` features have been executed once other non-core Cucumber features can be run via:
```
ssh -t head-ctl.tf.local cucumber spacewalk/testsuite/features/my_feature.feature
```


Get HTML results with:
```
scp head-ctl.tf.local://root/spacewalk-testsuite-base/output.html .
```

To keep the testsuite running after ending the ssh session using `screen` tool:
```
ssh -t head-ctl.tf.local screen run-testsuite
```

You can detach from the session at anytime using the key sequence `^A d`. To re-attach to the existing session:
```
ssh -t head-ctl.tf.local screen -r
```

You can configure a `mirror` host for the testsuite and that will be beneficial deploy performance, but presently an Internet connection will still be needed to deploy test hosts correctly.

You can also select [a specific branch of the Cucumber testsuite git repo](https://github.com/SUSE/spacewalk-testsuite-base/#branches-used) via the `branch` variable in the `controller` module (by default an automatic selection is made).

## Working on multiple configuration sets (workspaces) locally

Terraform supports working on multiple infrastructure resource groups with the same set of files through the concept of [workspaces](https://www.terraform.io/docs/state/workspaces.html). Unfortunately those are not supported for the default filesystem backend and do not really work well with different `main.tf` files, which is often needed in sumaform.

As a workaround, you can create a `local_workspaces` directory with a subdirectory per workspace, each containing main.tf and terraform.tfstate files, then use symlinks to the sumaform root:

```
~/sumaform$ find local_workspaces/
local_workspaces/
local_workspaces/aws-demo
local_workspaces/aws-demo/main.tf
local_workspaces/aws-demo/terraform.tfstate
local_workspaces/libvirt-testsuite
local_workspaces/libvirt-testsuite/main.tf
local_workspaces/libvirt-testsuite/terraform.tfstate
~/sumaform$ ls -l main.tf
[...] main.tf -> local_workspaces/libvirt-testsuite/main.tf
~/sumaform$ ls -l terraform.tfstate
[...] -> local_workspaces/libvirt-testsuite/terraform.tfstate
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

Please note for the Java probes to work the `java_debugging` setting has to be enabled in the `suse_manager_server` module (it is by default).

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

## Use Locust for http load testing

You can deploy a locust host to test http performance of your SUSE Manager Server. An example would be:

```hcl
module "locust" {
  source = "./modules/libvirt/locust"
  base_configuration = "${module.base.configuration}"
  server_configuration = "${module.suma31pg.configuration}"
  // optionally, specify a custom locustfile:
  // locust_file = "./my_locustfile.py"
}
```

If `locust_file` is not specified, a minimal example is installed. To run the load test, execute `run-locust` on the Locust host.

This host can also be monitored via Prometheus and Grafana by adding `locust_configuration` to a `grafana` module:

```hcl
module "grafana" {
  source = "./modules/libvirt/grafana"
  base_configuration = "${module.base.configuration}"
  server_configuration = "${module.suma31pg.configuration}"
  locust_configuration = "${module.locust.configuration}"
}
```

## Use SUSE Linux Enterprise updates (released and unreleased)

It is possible to run SUSE Manager servers, proxies, clients and minions with the latest packages instead of outdated ones, including updates currently in QAM, that is, upcoming updates. This is useful to spot regressions early, and can be activated via the `use_released_updates` (respectively `use_unreleased_updates`) flag. Libvirt example:

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
