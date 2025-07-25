# Advanced `main.tf` configurations

## Changing product versions

Some modules have a `product_version` variable that determines the software product version. Specifically:

- in `server`, `proxy`, `server_containerized` and `proxy_containerized`, `product_version` determines the SUSE Manager/Uyuni product version
- in `minion`, `client`, etc. `product_version` determines the SUSE Manager/Uyuni Tools version

Legal values for released software are:

- `4.3-released` (latest released maintenance update for SUSE Manager 4.3 and Tools)
- `4.3-VM-released` (latest released maintenance update for SUSE Manager 4.3 virtual machine)
- `5.0-released` (latest released maintenance update for SUSE Manager 5.0 and Tools)
- `5.1-released` (latest released maintenance update for Multi Linux Manager 5.1 and Tools)
- `uyuni-released` (latest released version for Uyuni Server, Proxy and Tools, from systemsmanagement:Uyuni:Stable)

Legal values for work-in-progress software are:

- `4.3-nightly` (corresponds to the Build Service project Devel:Galaxy:Manager:4.3)
- `4.3-VM-nightly` (corresponds to the VM image in the Build Service project Devel:Galaxy:Manager:4.3)
- `5.0-nightly` (corresponds to the Build Service project Devel:Galaxy:Manager:5.0)
- `5.1-nightly` (corresponds to the Build Service project Devel:Galaxy:Manager:5.1)
- `head` (corresponds to the Build Service project Devel:Galaxy:Manager:Head, uses SL Micro 6.1 as the base image for server)
- `uyuni-master` (corresponds to the Build Service project systemsmanagement:Uyuni:Master, for `server` and `proxy` only works with openSUSE Leap image)

**Important:** sumaform only supports containerized deployments for SUSE Manager versions 5.0 and later.
Please use `server_containerized` and `proxy_containerized` modules with product versions `head` and `5.0-X`.

Legal values for CI:

`uyuni-pr` is a special product version used internally to test Pull Requests. Packages are under a subproject in systemsmanagement:Uyuni:Master:TEST and systemsmanagement:Uyuni:Master:PR.
This is not meant to be used outside the Continous Integration system (CI).

Similarly, `4.3-pr` is used for testing Pull Requests on Manager-4.3.

Because packages are under different subprojects for each CI run and each Pull Request, repositories will be added later as additional repositories.

Note: the version of Salt on minions is determined by this value, as Salt is obtained from SUSE Manager Tools repos.

Note: on clients and minions only, the version number can be omitted to take the default for the distribution, eg. `released` and `nightly` are legal values.

A libvirt example follows:

```hcl
module "suse_minion" {
  source = "./modules/minion"
  base_configuration = module.base.configuration

  name = "min-sles15sp6"
  image = "sles15sp6o"
  server_configuration = module.proxy.configuration
  product_version = "5.0-nightly"
}

module "server" {
  source = "./modules/server"
  base_configuration = module.base.configuration

  name = "server"
  product_version = "5.0-released"
}
```

## Changing Operating Systems

You can specify a base OS in most modules specifying an `image` variable.

For some modules like `minion`, `image` is mandatory and Terraform will refuse to apply plans if it is missing. Please refer to `modules/<backend>/base/main.tf` for the exact list of supported OSs.

For other modules like `server` there is a default selection if nothing is specified. Please note that not all OS combinations might be supported, refer to official documentation to select a compatible OS.

The following example creates a SUSE Manager server using "nightly" packages from version 5.0 based on SLES 15 SP3:

```hcl
module "server" {
  source = "./modules/server"
  base_configuration = module.base.configuration

  image = "sles15sp3o"
  name = "server"
  product_version = "5.0-nightly"
}
```

### Official OS images

Many projects/vendors provide official OS images for the various backends, and sumaform uses them when available. The name for those images is suffixed with an "o" (eg. `sles15o`).

## Switching to another backend

Changing the backend normally means destroying the current one (see "Working on multiple configuration sets" to maintain multiple).

The following steps need to be performed:

- Clean the current Terraform state
  - Consider run `terraform destroy`
  - Remove the `terraform.tfstate` file
- Adapt the `main.tf` file to the new provider specific properties
- remove folder `.terraform`
- Create a new backend symbolic link to point to the new backend. From the `modules` folder run:

```bash
ln -sfn ../backend_modules/<BACKEND> modules/backend
```

## Multiple VMs of the same type

Some modules, for example clients and minions, support a `quantity` variable that allows you to create several instances at once. For example:

```hcl
module "suse_minion" {
  source = "./modules/minion"
  base_configuration = module.base.configuration

  name = "min-sles12sp5"
  image = "sles12sp5o"
  server_configuration = module.server.configuration
  quantity = 10
}
```

This will create 10 minions connected to the `server`.

## Jenkins (PoC)

If you are running `sumaform` for Uyuni and you want Continuous Integration, you can a setup a Jenkins instance using the `jenkins` module.

For now, the module provides Jenkins with the following plugins enabled:

- swarm
- git
- git-client
- workflow-aggregator
- extended-choice-parameter
- timestamper
- htmlpublisher
- rebuild
- http_request
- ansicolor
- greenballs

Authentication is enabled, and a user `admin` is created. The password can be found at `/var/lib/jenkins/secrets/initialAdminPassword` at the Jenkins instance.

To enable Jenkins, use the following definition:

```hcl
module "jenkins" {
  source             = "./modules/jenkins"
  base_configuration = module.base.configuration
}
```

Usually you will want to use this on public clouds, but if you want to use this in libvirt, you are encouraged to use a separate pool, as explained for the mirror below.

## Mirror

If you are using `sumaform` outside of the SUSE Nuremberg network you should use a special extra virtual machine named `mirror` that will cache packages downloaded from the SUSE engineering network for faster access and lower bandwidth consumption.

It will be be used exclusively by other VMs to download SUSE content - that means your SUSE Manager servers, clients, minions and proxies will be "fully disconnected", not requiring Internet access to operate.

To enable `mirror`, add `mirror = "mirror.tf.local"` to the `base` section in `main.tf` and add the following module definition:

```hcl
module "mirror" {
  source = "./modules/mirror"
  base_configuration = module.base.configuration

  volume_provider_settings = {
    pool = "data"
  }
}
```

Note you are encouraged to specify an additional libvirt storage pool name (`data` in the example above). Downloaded content will be placed on a separate disk in this pool - it helps SUSE Manager performance significantly if the pool is mapped onto a different physical disk. You can configure a pool with `virt-manager` like in the following image:

![data pool configuration in virt-manager](/help/data-pool-configuration.png)

Omitting the `volume_provider_settings` `pool` variable results in the default "default" storage pool being used.

The `mirror` can also synchronize Ubuntu official repositories.
To enable mirroring Ubuntu versions add the corresponding version numbers to the `ubuntu_distros` variable as follows:

```hcl
module "mirror" {
  source = "./modules/mirror"
  base_configuration = module.base.configuration

  ubuntu_distros = ['20.04', '22.04', '24.04']
}
```

Note that `mirror` must be populated before any host can be deployed. By default, its cache is refreshed nightly via `cron`, as configured in `/etc/cron.daily`. You can also schedule a one-time refresh by running manually some of the scripts that reside in `/usr/local/bin` directory.

## Mirror only for Server (products synchronization)

In addition to the parameter `mirror`, which will wrap this case, you might only want to setup a mirror for server products synchronization, but not for the repositories used by sumaform during the deployment of your environment.
For that use case, instead of `mirror` use `server_mounted_mirror` parameter inside the server module definition.

## External Web Server to store previous reports

Using the variable `web_server_hostname` in the `controller` module, we will provide the FQDN of an external web server. This allows us to mount an NFS partition on the controller module at `/srv/www`.
Doing so enables the controller to send the current report to that external location, which may be publicly accessible from the internet.
This setup is useful because the controller, and usually the entire environment, is located in a private network, preventing users from accessing the results directly.

## Virtual hosts

Virtualization hosts are Salt minions that are also capable to run virtual machines using the KVM hypervisor.

An example follows:

```hcl
module "virthost" {
  source = "./modules/virthost"
  base_configuration = module.base.configuration
  server_configuration = module.srv.configuration
  ...
  name = "min-kvm"
  image = "sles15sp6o"
  ...
  provider_settings = {
    vcpu = 3
    memory = 2048
  }
}
```

The created virtual host will get the same CPU model its host has.
This means that in order for virtual hosts to host virtual machines, nested virtualization has to be enabled on the physical machine.
For this, the `kvm_intel` or `kvm_amd` kernel modules need to have `nested` parameter set to `1`.
To check if nested virtualization is enabled on the physical machine, the following command needs to return either `1` or `Y`:

```bash
# For intel CPU:
cat /sys/module/kvm_intel/parameters/nested

# For AMD CPU:
cat /sys/module/kvm_amd/parameters/nested
```

The generated virtual host will be setup with:

- a `default` virtual network or `nat` type with `192.168.42.1/24` IP addresses,
- a `default` virtual storage pool of `dir` type targeting `/var/lib/libvirt/images`
- and a VM template disk image located in `/var/testsuite-data/`.

The openSUSE Leap template (`leap`) disk image is `opensuse156o` used by sumaform and is downloaded when applying the
highstate on the virtual host.
In order to use another or a cached image, use the `hvm_disk_image` variable.
If the values inside the `hvm_disk_image` map are set to an empty map, no image will be copied to `/var/testsuite-data/`.
For example, to use a local image, copy it to the `salt/virthost/` folder and set the `image` key inside the `leap`
hashmap of `hvm_disk_image` to `"leap = salt://virthost/imagename.qcow2"`. See the [Virtual host](https://github.com/uyuni-project/sumaform/blob/master/README_TESTING.md#virtual-host) section inside of README_TESTING for an example.

## Turning convenience features off

By default, sumaform deploys hosts with a range of tweaked settings for convenience reasons. If in your use case this is not wanted, you can turn those off via the following variables.

 * `client` module:
   * `auto_register`: automatically registers clients to the SUSE Manager Server. Set to `false` for manual registration
   * `disable_firewall`: disables the firewall making all ports available to any host. Set to `false` to only have typical SUSE Manager ports open
   * `sles_registration_code` : only for sles, register client with SCC key and enable modules during deployment. Set to `null` by default to use repositories for deployment  
 * `minion` module:
   * `auto_connect_to_master`: automatically connects to the Salt Master. Set to `false` to manually configure
   * `disable_firewall`: disables the firewall making all ports available to any host. Set to `false` to only have typical SUSE Manager ports open
   * `sles_registration_code` : only for sles, register client with SCC key and enable modules during deployment. Set to `null` by default to use repositories for deployment
 * `sshminion` module:
   * `disable_firewall`: disables the firewall making all ports available to any host. Set to `false` to only have typical SUSE Manager ports open
 * `host` module:
   * `disable_firewall`: disables the firewall making all ports available to any host. Set to `false` to only have typical SUSE Manager ports open
 * `proxy` module:
   * `minion`: whether to configure this Proxy as a Salt minion. Set to `false` to have the Proxy set up as a traditional client
   * `auto_connect_to_master`: automatically connects to the Salt Master. Set to `false` to manually configure. Requires `minion` to be `true`
   * `auto_register`: automatically registers the proxy to its upstream Server or Proxy. Defaults to `false`, requires `minion` to be `false`
   * `download_private_ssl_key`: automatically copies SSL certificates from the upstream SUSE Manager Server or SUSE Manager Proxy. Requires `publish_private_ssl_key` on the upstream server or proxy. Set to `false` for manual distribution
   * `install_proxy_pattern`: install proxy pattern with all proxy-related software. Set to `false` to install manually
   * `auto_configure`: automatically runs the `confure-proxy.sh` script which enables Proxy functionality. Set to `false` to run manually. Requires `auto_register`, `download_private_ssl_key`, and `install_proxy_pattern`
   * `generate_bootstrap_script`: generates a bootstrap script for traditional clients and copies it in /pub. Set to `false` to generate manually. Requires `auto_configure`
   * `publish_private_ssl_key`: copies the private SSL key in /pub for cascaded Proxies to copy automatically. Set to `false` for manual distribution. Requires `download_private_ssl_key`
   * `disable_firewall`: disables the firewall making all ports available to any host. Set to `false` to only have typical SUSE Manager ports open
   * `proxy_registration_code` : register proxy with SCC key and enable modules needed for SUMA Proxy during deployment. Set to `null` by default to use repositories for deployment
 * `server` module:
   * `auto_accept`: whether to automatically accept minion keys. Set to `false` to manually accept
   * `create_first_user`: whether to automatically create the first user (the SUSE Manager Admin)
     * `server_username` and `server_password`: define credentials for the first user, admin/admin by default
   * `disable_firewall`: disables the firewall making all ports available to any host. Set to `false` to only have typical SUSE Manager ports open
   * `allow_postgres_connections`: configure Postgres to accept connections from external hosts. Set to `false` to only allow localhost connections
   * `unsafe_postgres`: use PostgreSQL settings that improve performance by worsening durability. Set to `false` to ensure durability
   * `skip_changelog_import`: import RPMs without changelog data, this speeds up spacewalk-repo-sync. Set to `false` to import changelogs
   * `mgr_sync_autologin`: whether to set mgr-sync credentials in the .mgr-sync file. Requires `create_first_user`
   * `create_sample_channel`: whether to create an empty test channel. Requires `create_first_user`
   * `create_sample_activation_key`: whether to create a sample activation key. Requires `create_first_user`
   * `create_sample_bootstrap_script`: whether to create a sample bootstrap script for traditional clients. Requires `create_sample_activation_key`
   * `publish_private_ssl_key`: copies the private SSL key in /pub for Proxies to copy automatically. Set to `false` for manual distribution
   * `disable_download_tokens`: disable package token download checks. Set to `false` to enable checking
   * `forward_registration`: enable forwarding of registrations to SCC (default off)
   * `server_registration_code` : register server with SCC key and enable modules needed for SUMA Server during deployment. Set to `null` by default to use repositories for deployment
   * `login_timeout`: define how long the webUI login cookie is valid (in seconds). Set to null by default to leave it up to the application default value.
   * `db_configuration` : pass external database configuration to change `setup_env.sh` file. See more in `Using external database` section
   * `beta_enabled`: enable beta channels in rhn configuration. Set to false by default.
 * `controller` module:
   * `is_using_paygo_server`: whether to use the paygo server. Set to `false` to use the default server
   * `is_using_build_image`: whether to use the build image. Set to `false` to use the default image
   * `is_using_scc_repositories`: whether to use SCC repositories. Set to `false` to use the default repositories
   * `catch_timeout_message`: whether to catch timeout messages. Set to `false` to use the default timeout message
   * `beta_enabled`: enable beta channels in rhn configuration. Set to false by default.

## Adding channels to SUSE Manager Servers

You can specify a set of SUSE official channels to be added at deploy time of a SUSE Manager Server. This operation is typically time-intensive, thus it is disabled by default. In order to add a channel, first get the label name from an existing SUSE Manager Server:

```bash
# mgr-sync list channels --compact
Available Channels:
...
[ ] sles12-sp5-pool-x86_64
```

Then add it to the `channels` variable in a SUSE Manager Server module:

```hcl
module "server" {
  source = "./modules/server"
  base_configuration = module.base.configuration

  name = "server"
  product_version = "5.0-nightly"
  channels = ["sles12-sp5-pool-x86_64"]
}
```

Setting the `wait_for_reposync` variable to `true` will result into sumaform waiting for reposync to finish after channels are added.

## Cloning channels in SUSE Manager Servers upon deployment

Channels specified via the `channels` variable above can be automatically cloned by date at deploy time. This operation is typically time-intensive, thus it is disabled by default. In order to clone channels specified via the `channels` variable, you need to specify the cloning details in a `cloned_channels` variable according to the following syntax:

```hcl
[{ channels = ["<PARENT_CHANNEL_NAME>", "<CHILD_CHANNEL_1_NAME>", ...],
  prefix   = "<CLONE_PREFIX>",
  date     = "<YYYY-MM-DD>"
}]
```

A libvirt example follows:

```hcl
module "server" {
  source = "./modules/server"
  base_configuration = module.base.configuration

  name = "server"
  product_version = "5.0-nightly"
  channels = ["sles15-sp3-pool-x86_64", "sles15-sp3-updates-x86_64"]
  wait_for_reposync = true
  cloned_channels = [
    { channels = ["sles15-sp3-pool-x86_64", "sles15-sp3-updates-x86_64"],
      prefix   = "cloned-2017-q3",
      date     = "2017-09-30"
    }
  ]
}
```

At deploy time the `spacewalk-clone-by-date` will be used for each channel set. Note that it is required that the parent channel is always specified in the cloned channel list.

Activation keys are also automatically created for each clone with the name `1-<CLONE_PREFIX>`.

## Shared resources, prefixing, sharing virtual hardware

Whenever multiple sumaform users deploy to the same virtualization hardware (eg. libvirt host) it is recommended to set the `name_prefix` variable in the `base` module in order to have a unique per-user prefix for all resource names. This will prevent conflicting names.

Additionally, it is possible to have only one user to upload images and other shared infrastructure such as mirrors, having all other users re-use them. In order to accomplish this:

- add a `use_shared_resources = true` variable to the `base` module of all users but one
- make sure there is exactly one user that does not have the variable set, make sure this user has no `name_prefix` set. This user will deploy shared infrastructure for all users

## Disabling Avahi and Avahi reflectors

SUSE Manager requires both direct and reverse domain names resolution. This can be provided by either DNS (client-server, unicast mode) or Avahi (peer-to-peer, multicast mode, only for .local domain).

Note that Avahi is not available in environments that disable multicast UDP, notably AWS, so the following is only relevant for the libvirt backend, where it is enabled by default.

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

  provider_settings = {
    mac = "42:54:00:00:00:66"
  }
  ...
}
```

If Avahi is enabled and you are running Docker on a minion, you will need an Avahi reflector on the minion to provide multicast domain name resolution inside of the containers. A typical example is the Cucumber testsuite which uses such a setup. An Avahi reflector can be enabled via:

```hcl
module "minion" {
  ...
  avahi_reflector = true
  ...
}
```

If you will be adding Windows minions, you should disable Avahi in sumaform, as for historical reasons mDNS and resolution of .local and .lan is broken and will not work. Do not trust any source saying it works on Windows 10 (there are lots of "ifs" and "buts"), or can be fixed with Bonjour Printing Services (not for .local).

## Additional network

You may get an additional, isolated, network by specifying for example:

```hcl
module "base" {
  ...
  provider_settings = {
    additional_network = "192.168.5.0/24"
  }
  ...
}
```

This will create a network named `private`, with your prefix in front of the name (e.g. `prefix-private`).

You may use that additional network to test Cobbler or SUSE Manager for Retail with the test suite or manually.

For each VM, you can decide whether it connects to the base network and/or to the additional network by specifying:

```hcl
connect_to_base_network = false
connect_to_additional_network = true
```

When there are two connections, the first network interface `eth0` gets connected to base network, and the second interface `eth1` gets connected to the additional network.
When there is only one connection, the card is always `eth0`, no matter to which network it is connected.

Some modules have preset defaults: SUSE Manager/Uyuni servers and the testsuite controller connect only to the base network, while SUSE Manager/Uyuni proxies connect to both networks.

DHCP and DNS services for the additional network may be ensured by the proxy. Alternatively, you can install a DHCP and DNS server into the additional network by declaring:

```hcl
module "cucumber_testsuite" {
  ...
  host_settings = {
    ...
    dhcp-dns = {
      name = "dhcp-dns"
      image = "opensuse155o"
    }
    ...
  }
}
```

from the test suite module, or:

```hcl
module "dhcp-dns" {
  source = "./modules/dhcp_dns"

  name = "dhcp-dns"
  image = "opensuse155o"
  hypervisor = { host = "hypervisor.example.org", user = "root", private_key = file("~/.ssh/id_ed25519") }
  private_hosts = [ module.proxy.configuration, module.sles12sp5-terminal.configuration, module.sles15sp4-terminal.configuration ]
}
```

in a more direct manner. In both cases, you need to drop your public SSH key into `~/.ssh/authorized_keys` on the hypervisor.

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

```config
Host *.tf.local
StrictHostKeyChecking no
UserKnownHostsFile=/dev/null
User root
```

## Activation Keys for minions

You can specify an Activation Key string for minions to use at onboarding time to a SUSE Manager Server. An example follows:

```hcl
module "suse_minion" {
  source = "./modules/minion"
  base_configuration = module.base.configuration

  name = "min"
  image = "sles12sp5o"
  server_configuration = module.server.configuration
  activation_key = "1-DEFAULT"
}
```

## Proxies

A `proxy` module is similar to a `client` module but has a `product_version` and a `server` variable pointing to the upstream server. You can then point clients to the proxy, as in the example below:

```hcl
module "server" {
  source = "./modules/server"
  base_configuration = module.base.configuration

  name = "server"
  product_version = "4.3-nightly"
}

module "proxy" {
  source = "./modules/proxy"
  base_configuration = module.base.configuration

  name = "proxy"
  product_version = "4.3-nightly"
  server_configuration = module.server.configuration
}

module "suse_client" {
  source = "./modules/client"
  base_configuration = module.base.configuration

  name = "cli-sles12sp5"
  image = "sles12sp5o"
  server_configuration = module.proxy.configuration
  quantity = 3
}
```

Note that proxy chains (proxies of proxies) also work as expected. You can find a list of customizable variables for the `proxy` module in `modules/libvirt/proxy/variables.tf`.

Note that systems prepared by this module are by default registered as a Salt minions. If this is not desired you can switch off Salt minion registration by setting the `minion` flag to `false`:

```hcl
module "proxy" {
  source = "./modules/proxy"
  base_configuration = module.base.configuration

  name = "proxy"
  product_version = "5.0-nightly"
  server_configuration = module.server.configuration

  minion = false
}
```

## Inter-Server Sync (ISS)

Create two SUSE Manager server modules and add `iss_master` and `iss_slave` variable definitions to them, as in the example below:

```hcl
module "master" {
  source = "./modules/server_containerized"
  base_configuration = module.base.configuration

  name = "master"
  product_version = "head"
  iss_slave = "slave.tf.local"
}

module "slave" {
  source = "./modules/server_containerized"
  base_configuration = module.base.configuration

  name = "slave"
  product_version = "head"
  iss_master = module.master.configuration["hostname"]
}
```

Please note that `iss_master` is set from `master`'s module output variable `hostname`, while `iss_slave` is simply hardcoded. This is needed for Terraform to resolve dependencies correctly, as dependency cycles are not permitted.

## Working on multiple configuration sets (workspaces) locally

Terraform supports working on multiple infrastructure resource groups with the same set of files through the concept of [workspaces](https://www.terraform.io/docs/state/workspaces.html). Unfortunately those are not supported for the default filesystem backend and do not really work well with different `main.tf` files, which is often needed in sumaform.

As a workaround, you can create a `local_workspaces` directory with a subdirectory per workspace, each containing main.tf and terraform.tfstate files, then use symlinks to the sumaform root:

```bash
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

An example follows:

```hcl
module "vanilla" {
  source = "./modules/host"
  base_configuration = module.base.configuration

  name = "vanilla"
  image = "sles12sp5o"
}
```

## Build hosts

Build hosts have more repositories, so they can build Docker container and Kiwi images.

Building Kiwi images is needed for starting PXE boot hosts (see below) in Retail context.

An example follows:

```hcl
module "build_host"
{
  source = "./modules/build_host"
  base_configuration = module.base.configuration

  name = "buildhost"
  image = "sles15sp3o"
}
```

## PXE boot hosts

PXE boot hosts are unprovisioned hosts that are capable of booting from their networking card. Additionally, they have a hardware type of "Genuine Intel" to make provisioning via SUSE Manager for Retail easier.

"unprovisioned" means that they are completely unprepared: no SSH keys, no initialization at all.

SUSE Manager makes use of PXE booting in two use cases: cobbler, and Retail.

They are connected only to the private network.

An example follows:

```hcl
module "pxeboot_minion"
{
  source = "./modules/pxe_boot"
  base_configuration = module.base.configuration

  name = "pxeboot"
  image = "sles12sp5o"
  # last digit of the IP address and name on the private network:
  private_ip = 4
  private_name = "pxeboot"
}
```

## SMT

You can configure SUSE Manager instances to download packages from an SMT server instead of SCC, in case a `mirror` is not used:

```hcl
module "server" {
  source = "./modules/server"
  base_configuration = module.base.configuration

  name = "server"
  product_version = "5.0-nightly"
  smt = "http://smt.suse.de"
}
```

## Custom repos and packages

You can specify additional custom repos and packages to be installed at deploy time for a specific host:

```hcl
module "suse_minion" {
  source = "./modules/minion"
  base_configuration = module.base.configuration

  name = "min-sles12sp5"
  image = "sles12sp5o"
  server_configuration = module.server.configuration

  additional_repos = {
    virtualization_containers = "http://download.opensuse.org/repositories/Virtualization:/containers/SLE_12_SP2/"
  }

  additional_packages = [
    "terraform"
  ]
}
```

If you want to have full control over repos, you can also choose to disable all repos but those explicitly mentioned in `additional_repos` via the  `additional_repos_only` boolean variable.

If any repos or packages additionally need SSL certificates to be accessed, those can be added via the `additional_certs` variable:

```hcl
additional_certs = {
  RHN-ORG-TRUSTED-SSL-CERT = "http://server.tf.local/pub/RHN-ORG-TRUSTED-SSL-CERT"
}
```

## Add custom repo GPG keys

If you need extra GPG keys to be installed for package installation, you can add them via the `gpg_keys` list variable to a module.
The list contains paths relative to the `salt/` directory, as in the following example:

```hcl
module "suse-sshminion" {
  source = "./modules/host"
  base_configuration = module.base.configuration
  name = "minssh-sles12sp5"
  image = "sles12sp5o"
  gpg_keys = ["default/gpg_keys/galaxy.key"]
}
```

## Prometheus/Grafana monitoring

It is possible to install Prometheus exporters on a SUSE Manager Server instance via the `monitored` flag. Those can be consumed by Prometheus and Grafana server to analyze visually. A libvirt example follows:

```hcl
module "server" {
  source = "./modules/server_containerized"
  base_configuration = module.base.configuration

  name = "server"
  product_version = "head"
  monitored = true
}

module "grafana" {
  source = "./modules/grafana"
  base_configuration = module.base.configuration
  server_configuration = module.server.configuration
}
```

Grafana is accessible at [http://grafana.tf.local](http://grafana.tf.local) with username and password `admin`.

Please note for the Java probes to work the `java_debugging` setting has to be enabled in the `server` module (it is by default).

## Container registry

You can run a basic container registry as per the following example:

```hcl
module "registry" {
  source = "./modules/registry"
  base_configuration = module.base.configuration

  name = "registry"
}
```

The registry will be available on port 80 (unencrypted http) and without authentication.

## [evil-minions](https://github.com/uyuni-project/evil-minions) load generator

`evil-minions` is a Salt load generator useful for performance tests and demoing. It contains tools to "record" behavior of a Salt minion and to "play it back" multiple times in parallel in order to test the Salt Master or SUSE Manager Server.

In order to create an `evil-minions` load generator, you have to define a regular `minion` module, and use the `evil_minion_count` variable on it. This will create an instance of a `minion`, and on top of it will set up the `evil-minions` load generator, which will create `evil_minion_count` replicas of the actual `minion`.

It is also possible to set up a delay on the response time of the replicas. By default, the replicas will respond as fast as possible, which might not be appropriate depending on the objectives of your simulation. To reproduce delays observed by the original minion, use the `evil_minion_slowdown_factor` variable, as follows:

- `0.0`, the default value, makes evil minions respond as fast as possible
- `1.0` makes `evil-minion` introduce delays to match the response times of the original minion
- `2.0` makes `evil-minion` react twice as slow as the original minion
- `0.5` makes `evil-minion` react twice as fast as the original minion

For more information, visit the `evil-minions` project page at [here](https://github.com/uyuni-project/evil-minions).

A libvirt example follows:

```hcl
module "minion" {
  source = "./modules/minion"
  base_configuration = module.base.configuration

  name = "minion"
  image = "sles15sp6o"
  server_configuration = module.server.configuration
  evil_minion_count = 10
  evil_minion_slowdown_factor = 1
}
```

## Use Locust for http load testing

You can deploy a locust host to test http performance of your SUSE Manager Server. An example would be:

```hcl
module "locust" {
  source = "./modules/locust"
  base_configuration = module.base.configuration
  server_configuration = module.server.configuration
  // optionally, specify a custom locustfile:
  // locust_file = "./my_locustfile.py"
}
```

If `locust_file` is not specified, a minimal example is installed. To run the load test, execute `run-locust` on the Locust host.

This host can also be monitored via Prometheus and Grafana by adding `locust_configuration` to a `grafana` module:

```hcl
module "grafana" {
  source = "./modules/grafana"
  base_configuration = module.base.configuration
  server_configuration = module.server.configuration
  locust_configuration = module.locust.configuration
}
```

In case you need to simulate a big amount of users, Locust's master-slave mode can be enabled by specifying a number of slaves:

```hcl
module "locust" {
  source = "./modules/locust"
  base_configuration = module.base.configuration
  server_configuration = module.server.configuration
  locust_file = "./my_heavy_locustfile.py"
  slave_quantity = 5
}
```

## Use Operating System released updates

It is possible to run SUSE Manager servers, proxies, clients and minions with the latest packages of the operating system (for now, only SLE is supported) instead of outdated ones. This is useful to spot regressions early, and can be activated via the `use_os_released_updates` flag. Libvirt example:

```hcl
module "server" {
  source = "./modules/server_containerized"
  base_configuration = module.base.configuration

  name = "server"
  product_version = "head"
  use_os_released_updates = true
}
```

## Email configuration

With the default configuration, whenever SUSE Manager server hosts are configured to use root@`hostname -d` as the email sender. The recipient's SMTP server may discard those emails since they come from a non-existent domain name.

This setting can be overridden with a custom 'from' address by supplying the parameter: `from_email`. A libvirt example would be:

```hcl
module "server" {
  source = "./modules/server_containerized"
  base_configuration = module.base.configuration

  name = "server"
  product_version = "head"

  from_email = "root@mbologna.openvpn.suse.de"
}
```

Internal Server Errors and relative stacktraces are sent via e-mail by default to `galaxy-noise@suse.de`.
By suppling the parameter `traceback_email` you can override that address to have them in your inbox:

```hcl
module "sumamail3" {
  source = "./modules/server_containerized"
  base_configuration = module.base.configuration

  name = "sumamail3"
  product_version = "head"

  traceback_email = "michele.bologna@chameleon-mail.com"
}
```

## Swap file configuration

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

## Additional disk on Server or Proxy

In case the default disk size for those machines is not enough for the amount of products you want to synchronize, you can add an additional disk which will mount the first volume in `/var/spacewalk` with size `repository_disk_size` and the second volume in `/var/lib/pgsql` with size `database_disk_size`. This additional disk will be created in the pool specified by `data_pool`.

An example follows:

```hcl
module "server" {
  source = "./modules/server"
  base_configuration = module.base.configuration
  product_version = "5.0-nightly"
  name = "server"
  repository_disk_size = 500
  database_disk_size = 50
  volume_provider_settings = {
    data_pool = "default"
  }
}
```

## Large deployments

By default to support the load in our test suites, when trying to reproduce situations with a large number of clients, it is advised to use `large_deployment` option.
This option is inspired by the documentation at https://documentation.suse.com/suma/4.3/en/suse-manager/specialized-guides/large-deployments/tuning.html, and it will apply the following settings on the server:

```
### /etc/rhn/rhn.conf
taskomatic.com.redhat.rhn.taskomatic.task.MinionActionExecutor.parallel_threads = 3
hibernate.c3p0.max_size = 100

### /etc/tomcat/server.xml
changed `maxThreads` to 256

### /var/lib/pgsql/data/postgresql.conf
max_connections = 400
work_mem = 20MB
```

An example to disable it follows:

```hcl
module "server_containerized" {
   ...
   large_deployment = false
   ...
}
```

## Using a different FQDN

Normally, the fully qualified domain name (FQDN) is derived from `name` variable. However, some providers, like AWS cloud provider, impose a naming scheme that does not always match this mechanism. You may also want a name for libvirt that differs from the hostname part of the FQDN. The `overwrite_fqdn` variable allows the FQDN to diverge from the value normally derived from the name.

An AWS example is:

```hcl
module "cucumber_testsuite" {
  source = "./modules/cucumber_testsuite"
  ...
  host_settings = {
    ...
    server = {
      provider_settings = {
        instance_type = "m6a.xlarge"
        volume_size = "100"
        private_ip = "172.16.3.6"
        overwrite_fqdn = "uyuni-master-srv.sumaci.aws"
      }
    }
    ...
  }
  ...
}
```

A libvirt example is:

```hcl
module "opensuse155arm_minion" {
  source = "./modules/minion"
  ...
  name = "nue-min-opensuse155arm"
  ...
  provider_settings = {
    ...
    overwrite_fqdn   = "suma-bv-43-min-opensuse155arm.mgr.suse.de"
    ...
  }
  ...
}
```

Note the extra `nue-` in the name. With those settings, we have in libvirt:

```bash
suma-arm:~ # virsh list
 Id   Name                                   State
----------------------------------------------------
 ...
 11   suma-bv-43-nue-min-opensuse156arm      running
```

and inside the VM:

```bash
# hostname -f
suma-bv-43-min-opensuse156arm.mgr.suse.de
```


## Debugging facilities

The `server` module has options to automatically capture more diagnostic information, off by default:

- `java_debugging`: enable Java debugging and profiling support in Tomcat and Taskomatic
- `java_hibernate_debugging`: enable additional logs for Hibernate in Tomcat and Taskomatic
- `java_salt_debugging`: enable additional logs for Hibernate in Tomcat
- `postgres_log_min_duration`: log PostgreSQL statements taking longer than the duration (expressed as a string, eg. `250ms` or `3s`), or log all statements by specifying `0`

## Using an external database

Currently, sumaform only supports the RDS database as an external database. The server needs to be created in the public cloud (by default AWS). It's possible to get RDS in a private network shared with the server in AWS.

The RDS module returns automatically the parameters needed to configure `rhn.conf` through `setup_env.sh`.

| Output variable      | Type    | Description                                                               |
|----------------------|---------|---------------------------------------------------------------------------|
| `hostname`           | string  | RDS hostname that will be used for `MANAGER_DB_HOST` and `REPORT_DB_HOST` |
| `superuser`          | string  | Superuser to connect database                                             |
|                      |         | it will be used to create `MANAGER_USER` user and both databases          |
| `superuser_password` | string  | Superuser password                                                        |
| `port`               | string  | RDS port (by default `5432`)                                              |
| `certificate`        | string  | Certificate used to connect RDS database, provided by AWS                 |
| `local`              | boolean | Set to `false` to use an external database                                |

Example:

```hcl
module "rds" {
   source             = "./modules/rds"
   name               = ...
   base_configuration = module.base.configuration
   db_username        = ...
   db_password        = ...
}

module "server" {
  source = "./modules/server"
  base_configuration = module.base.configuration
  db_configuration = module.db.configuration
  ...
}
```
