# Advanced `main.tf` configurations

## Changing product versions

Some modules have a `product_version` variable that determines the software product version. Specifically:
 * in `suse_manager`, `suse_manager_proxy` etc. `product_version` determines the SUSE Manager product version,
 * in `minion`, `client`, etc. `product_version` determines the SUSE Manager Tools version.

Legal values for released software are:
 * `3.2-released`   (latest released Maintenance Update for SUSE Manager 3.2 and Tools)
 * `4.0-released`   (latest released Maintenance Update for SUSE Manager 4.0 and Tools)
 * `uyuni-released` (latest released version for Uyuni Server, Proxy and Tools, from systemsmanagement:Uyuni:Stable)

Legal values for work-in-progress software are:
 * `3.2-nightly` (corresponds to the Build Service project Devel:Galaxy:Manager:3.2)
 * `4.0-nightly` (corresponds to the Build Service project Devel:Galaxy:Manager:4.0)
 * `head` (corresponds to the Build Service project Devel:Galaxy:Manager:Head, for `suse_manager` and `suse_manager_proxy`only works with SLE15SP1 image)
 * `uyuni-master` (corresponds to the Build Service project systemsmanagement:Uyuni:Master, for `suse_manager` and `suse_manager_proxy` only works with openSUSE Leap 15.1 image)

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
  product_version = "nightly"
}

module "server" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "server"
  product_version = "3.2-released"
}
```

## Changing Operating Systems

You can specifiy a base OS in most modules specifying an `image` variable.

For some modules like `minion`, `image` is mandatory and Terraform will refuse to apply plans if it is missing. Please refer to `modules/<backend>/base/main.tf` for the exact list of supported OSs.

For other modules like `suse_manager` there is a default selection if nothing is specified. Please note that not all OS combinations might be supported, refer to official documentation to select a compatible OS.

The following example creates a SUSE Manager server using "nightly" packages from version 3.2 based on SLES 12 SP3:

```hcl
module "server" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  image = "sles12sp3"
  name = "server"
  product_version = "3.2-nightly"
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
  server_configuration = "${module.server.configuration}"
  count = 10
}
```

This will create 10 minions connected to the `server` server.


## Turning convenience features off

By default, sumaform deploys hosts with a range of tweaked settings for convenience reasons. If in your use case this is not wanted, you can turn those off via the following variables.

 * `client` module:
   * `auto_register`: automatically registers clients to the SUSE Manager Server. Set to `false` for manual registration
 * `minion` module:
   * `auto_connect_to_master`: automatically connects to the Salt Master. Set to `false` to manually configure
 * `suse_manager_proxy` module:
   * `minion`: whether to configure this Proxy as a Salt minion. Set to `false` to have the Proxy set up as a traditional client
   * `auto_connect_to_master`: automatically connects to the Salt Master. Set to `false` to manually configure. Requires `minion` to be `true`
   * `auto_register`: automatically registers the proxy to its upstream Server or Proxy. Defaults to `false`, requires `minion` to be `false`
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
module "server" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "server"
  product_version = "3.2-nightly"
  channels = ["sles12-sp2-pool-x86_64"]
}
```


## Cloning channels in SUSE Manager Servers upon deployment

Channels specified via the `channels` variable above can be automatically cloned by date at deploy time. This operation is typically time-intensive, thus it is disabled by default. In order to clone channels specified via the `channels` variable, you need to specify the cloning details in a `cloned_channels` variable according to the following syntax:

```yaml
[{ channels: [<PARENT_CHANNEL_NAME>, <CHILD_CHANNEL_1_NAME>, ...], prefix: <CLONE_PREFIX>, date: <YYYY-MM-DD> } ...]
```

A libvirt example follows:

```hcl
module "server" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "server"
  product_version = "3.2-nightly"
  channels = ["sles12-sp3-pool-x86_64", "sles12-sp3-updates-x86_64"]
  cloned_channels = "[{ channels: [sles12-sp3-pool-x86_64, sles12-sp3-updates-x86_64], prefix: cloned-2017-q1, date: 2017-03-31 }]"
}
```

At deploy time the `spacewalk-clone-by-date` will be used for each channel set. Note that it is required that the parent channel is always specified in the cloned channel list.

Activation keys are also automatically created for each clone with the name `1-<CLONE_PREFIX>`.


## Shared resources, prefixing, sharing virtual hardware

Whenever multiple sumaform users deploy to the same virtualization hardware (eg. libvirt host, OpenStack instance) it is recommended to set the `name_prefix` variable in the `base` module in order to have a unique per-user prefix for all resource names. This will prevent conflicting names.

Additionally, it is possible to have only one user to upload images and other shared infrastructure such as mirrors, having all other users re-use them. In order to accomplish this:
 * add a `use_shared_resources = true` variable to the `base` module of all users but one
 * make sure there is exactly one user that does not have the variable set, make sure this user has no `name_prefix` set. This user will deploy shared infrastructure for all users


## Disabling Avahi and Avahi reflectors

SUSE Manager requires both direct and reverse domain names resolution. This can be provided by either DNS (client-server, unicast mode) or Avahi (peer-to-peer, multicast mode).

Note that Avahi is not available in environments that disable multicast UDP, notably AWS, so the following is only relevant for the libvirt and OpenStack backends. Backends which support multicast UDP have Avahi enabled by default.

Avahi can be disabled if it is not needed. A typical example is a libvirt environment in bridged networking mode where all VMs have static MAC addresses and DNS names known in advance. Avahi can be disabled via something like:

```hcl
module "base" {
  ...
  use_avahi = false
  domain = "mgr.suse.de"
  ...
}

module "server" {
  ...
  mac = "42:54:00:00:00:66"
  ...
}
```

If Avahi is enabled and you are running Docker on a minion, you will need an Avahi reflector on the minion to provide Avahi resolution inside of the containers. A typical example is the Cucumber testsuite which uses such a setup. An Avahi reflector can be enabled via:

```hcl
module "minion" {
  ...
  avahi_reflector = true
  ...
}
```

Beware this may trigger [a known Avahi bug](https://github.com/lathiat/avahi/issues/117). This bug causes wrong names to be assigned to hosts (with unexpected `-2`, `-3`, etc. suffixes) in many circumstances, in particular when more than one reflector is in use on the same network.


## Additional network and SUSE Manager for Retail

You may get an additional, isolated, network, with neither DHCP nor DNS by specifying for example:

```hcl
module "base" {
  ...
  additional_network = "192.168.5.0/24"
  ...
}
```

This will create a network named `private`, with your prefix in front of the name (e.g. `prefix-private`).

You may use that additional network to test SUSE Manager for Retail with the test suite or manually.

For each VM, you can decide whether it connects to the base network and/or to the additional network by specifying:

```hcl
connect_to_base_network = false
connect_to_additional_network = true
```

When there are two connections, the first network interface `eth0` gets connected to base network, and the second interface `eth1` gets connected to the additional network.
When there is only one connection, the card is always `eth0`, no matter to which network it is connected.

Some modules have preset defaults: SUSE Manager/Uyuni Servers and the testsuite controller connect only to the base network, while SUSE Manager/Uyuni Proxies and clients or minions connect to both networks.


## Custom SSH keys

If you want to use another key for all VMs, specify the path of the public key with `ssh_key_path` into the `base` config. Example:

```hcl
module "base" {
  ...
  ssh_key_path = "~/.ssh/id_mbologna_terraform.pub"
  ...
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
  server_configuration = "${module.server.configuration}"
  activation_key = "1-DEFAULT"
}
```


## Proxies

A `proxy` module is similar to a `client` module but has a `product_version` and a `server` variable pointing to the upstream server. You can then point clients to the proxy, as in the example below:

```hcl
module "server" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "server"
  product_version = "3.2-nightly"
}

module "proxy" {
  source = "./modules/libvirt/suse_manager_proxy"
  base_configuration = "${module.base.configuration}"

  name = "proxy"
  product_version = "3.2-nightly"
  server_configuration = "${module.server.configuration}"
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

Note that systems prepared by this module are by default registered as a Salt minions. If this is not desired you can switch off Salt minion registration by setting the `minion` flag to `false`:

```hcl
module "proxy" {
  source = "./modules/libvirt/suse_manager_proxy"
  base_configuration = "${module.base.configuration}"

  name = "proxy"
  product_version = "3.2-nightly"
  server_configuration = "${module.server.configuration}"

  minion = false
}
```


## Inter-Server Sync (ISS)

Create two SUSE Manager server modules and add `iss_master` and `iss_slave` variable definitions to them, as in the example below:

```hcl
module "master" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "master"
  product_version = "3.2-released"
  iss_slave = "slave.tf.local"
}

module "slave" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "slave"
  product_version = "3.2-released"
  iss_master = "${module.master.configuration["hostname"]}"
}
```

Please note that `iss_master` is set from `master`'s module output variable `hostname`, while `iss_slave` is simply hardcoded. This is needed for Terraform to resolve dependencies correctly, as dependency cycles are not permitted.

Also note that this requires `create_first_user` and `publish_private_ssl_key` settings to be true (they are by default).


## Performance testsuite

It is possible to run the Performance testsuite for SUSE Manager by defining a "pts" module. This will create a test server, a locust load server, an minion instance with evil-minions running on it and (by default) a grafana host to monitor them.

A libvirt example follows:

```hcl
module "pts" {
  source = "./modules/libvirt/pts"
  base_configuration = "${module.base.configuration}"
}
```

To run the complete testsuite, run `run-pts` from the server, eg.:

```
ssh server.tf.local run-pts
```

It is possible to run only the locust HTTP load test, as follows:

```
ssh server.tf.local run-pts --locust-only
```

You can also run only the system patching test, as follows:

```
ssh server.tf.local run-pts --patching-only
```

It is also possible to specify non-default hostnames and MAC addresses, see `pts/variables.tf`.


## Cucumber testsuite

It is possible to run [the Cucumber testsuite for SUSE Manager and Uyuni](https://github.com/uyuni-project/uyuni/tree/master/testsuite) by using the `main.tf.libvirt-testsuite.example` file. This will create a test server, client and minion instances, plus a coordination node called a `controller` which runs the testsuite.

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

Read HTML results at:

 `head-ctl.tf.local/output.html`. There is an additional running service, enabled during the `highstate`, on the `controller` which is exposing the entire `/root/spacewalk/testsuite` folder: all testsuite files, including results saved under this folder, are readable through the `http` protocol at the port `80`.

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

You can also select an alternative fork or branch where for the Cucumber testsuite code:
 - the `git_repo` variable in the `controller` overrides the fork URL (by default either the Uyuni or the SUSE Manager repository is used)
 - the `branch` variable in the `controller` overrides the branch (by default an automatic selection is made).

As an example:

```hcl
module "controller" {
  source = "./modules/libvirt/controller"
  base_configuration = "${module.base.configuration}"
  name = "controller"
  ...
  git_repo = "https://url.to.git/repo/to/clone"
  branch = "cool-feature"
  ...
}
```

You can also use Docker and Kiwi profiles other than the ones embedded in the test suite:

```hcl
module "controller" {
  git_profiles_repo = "https://github.com#mybranch:myprofiles"
}

```


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
... main.tf -> local_workspaces/libvirt-testsuite/main.tf
~/sumaform$ ls -l terraform.tfstate
... -> local_workspaces/libvirt-testsuite/terraform.tfstate
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


## PXE boot hosts

PXE boot hosts are unprovisioned hosts that are capable of booting from their networking card. Additionally, they have a hardware type of "Genuine Intel" to make provisioning via SUSE Manager for Retail easier.

"unprovisioned" means that they are completly unprepared: no SSH keys, no initialization at all.

A libvirt example follows:

```hcl
module "pxeboot"
{
  source = "sumaform/modules/libvirt/pxe_boot"
  base_configuration = "${module.base.configuration}"

  name = "pxeboot"
  image = "sles12sp3"
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
  server_configuration = "${module.server.configuration}"
}
```

This will create 400 minions on 2 swarm hosts. Currently only SLES 12 SP1 with the released Salt version are supported.


## SMT

You can configure SUSE Manager instances to download packages from an SMT server instead of SCC, in case a `mirror` is not used:

```hcl
module "server" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "server"
  product_version = "3.2-nightly"
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
  server_configuration = "${module.server.configuration}"

  additional_repos {
    virtualization_containers = "http://download.opensuse.org/repositories/Virtualization:/containers/SLE_12_SP2/"
  }

  additional_packages = [
    "terraform"
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
module "server" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "server"
  product_version = "head"
  monitored = true
}

module "grafana" {
  source = "./modules/libvirt/grafana"
  base_configuration = "${module.base.configuration}"
  server_configuration = "${module.server.configuration}"
}
```

Grafana is accessible at http://grafana.tf.local with username and password `admin`.

Please note for the Java probes to work the `java_debugging` setting has to be enabled in the `suse_manager_server` module (it is by default).


## AppArmor access control

Optional access control via AppArmor and Audit Daemon can be enforced on a SUSE Manager server, proxy, or SUSE minion. It is not implemented for CentOS, because the kernel of that system is compiled without AppArmor support.

A libvirt example follows:

```hcl
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "server"
  product_version = "head"
  apparmor = true
```

The access control uses AppArmor profiles provided by sumaform in directories `salt/*/apparmor.d/`.

On the running host, AppArmor is initially in "complain" mode. The detected violations go to `/var/log/audit/audit.log`. You may incorporate these violations into the profiles with the command:
```
# aa-logprof
```

If you want to switch to "enforce" mode:
```
# aa-enforce /etc/apparmor.d/*
# systemctl reload apparmor.service
```

You may also start collecting new profiles with:
```
# aa-genprof <name of executable>
```

## [evil-minions](https://github.com/moio/evil-minions) load generator

`evil-minions` is a Salt load generator useful for performance tests and demoing. It contains tools to "record" behavior of a Salt minion and to "play it back" multiple times in parallel in order to test the Salt Master or SUSE Manager Server.

In order to create an `evil-minions` load generator, you have to define a regular `minion` module, and use the `evil_minion_count` variable on it. This will create an instance of a `minion`, and on top of it will set up the `evil-minions` load generator, which will create `evil_minion_count` replicas of the actual `minion`.

It is also possible to set up a delay on the response time of the replicas. By default, the replicas will respond as fast as possible, which might not be appropriate depending on the objectives of your simulation. To reproduce delays observed by the original minion, use the `evil_minion_slowdown_factor` variable, as follows:

 - `0.0`, the default value, makes evil minions respond as fast as possible
 - `1.0` makes `evil-minion` introduce delays to match the response times of the original minion
 - `2.0` makes `evil-minion` react twice as slow as the original minion
 - `0.5` makes `evil-minion` react twice as fast as the original minion

For more information, visit the `evil-minions` project page at https://github.com/moio/evil-minions/ .

A libvirt example follows:

```hcl
module "minion" {
  source = "./modules/libvirt/minion"
  base_configuration = "${module.base.configuration}"

  name = "minion"
  image = "sles15sp1"
  server_configuration = "${module.server.configuration}"
  evil_minion_count = 10
  evil_minion_slowdown_factor = 1
}
```


## Use Locust for http load testing

You can deploy a locust host to test http performance of your SUSE Manager Server. An example would be:

```hcl
module "locust" {
  source = "./modules/libvirt/locust"
  base_configuration = "${module.base.configuration}"
  server_configuration = "${module.server.configuration}"
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
  server_configuration = "${module.server.configuration}"
  locust_configuration = "${module.locust.configuration}"
}
```

In case you need to simulate a big amount of users, Locust's master-slave mode can be enabled by specifying a number of slaves:

```hcl
module "locust" {
  source = "./modules/libvirt/locust"
  base_configuration = "${module.base.configuration}"
  server_configuration = "${module.server.configuration}"
  locust_file = "./my_heavy_locustfile.py"
  slave_count = 5
}
```


## Use Operating System updates (released and unreleased)

It is possible to run SUSE Manager servers, proxies, clients and minions with the latest packages of the operating system (for now, only SLE is supported) instead of outdated ones, including updates currently in QAM, that is, upcoming updates. This is useful to spot regressions early, and can be activated via the `use_os_released_updates` (respectively `use_os_unreleased_updates`) flag. Libvirt example:

```hcl
module "sumaheadpg" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "sumaheadpg"
  product_version = "head"
  use_os_unreleased_updates = true
}
```


## E-mail configuration

With the default configuration, whenever SUSE Manager server hosts are configured to use root@`hostname -d` as the email sender. The recipient's SMTP server may discard those emails since they come from a non-existent domain name.

This setting can be overridden with a custom 'from' address by supplying the parameter: `from_email`. A libvirt example would be:

```hcl
module "server" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "server"
  product_version = "head"

  from_email = "root@mbologna.openvpn.suse.de"
}
```

Internal Server Errors and relative stacktraces are sent via e-mail by default to `galaxy-noise@suse.de`.
By suppling the parameter `traceback_email` you can override that address to have them in your inbox:

```hcl
module "sumamail3" {
  source = "./modules/libvirt/suse_manager"
  base_configuration = "${module.base.configuration}"

  name = "sumamail3"
  product_version = "head"

  traceback_email = "michele.bologna@chameleon-mail.com"
}
```


# Swap file configuration

You can add a swap file to most hosts, to prevent out-of-memory conditions.

Please note that some systems already come with some swap file or swap partition of their own: Ubuntu and CentOS minions, and
SUSE Manager server.

A libvirt example is:

```hcl
module "minion" {
   ...
   swap_file_size = 2048 // in MiB
   ...
}
```

To disable the swap file, set its size to 0.
