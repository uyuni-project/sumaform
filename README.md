# sumaform

![Sumicform, a green hedgehog made of bricks, sumaform's mascot](help/sumicform.png)

`sumaform` is a way to quickly configure test SUSE Manager setups with clients and servers.

It got its [portmanteau](https://en.wikipedia.org/wiki/Portmanteau) name being the successor of [suminator](https://github.com/SUSE/suminator/) implemented as [Terraform](https://www.terraform.io/) modules.

## Installation

- OpenSUSE Leap 42.1
  ```
  sudo zypper addrepo http://download.opensuse.org/repositories/home:/SilvioMoioli:/tools/openSUSE_Leap_42.1/home:SilvioMoioli:tools.repo
  sudo zypper install terraform-provider-libvirt
  git clone gitlab@gitlab.suse.de:mbologna/sumaform.git
  ```
- OpenSUSE Tumbleweed
  ```
  sudo zypper addrepo http://download.opensuse.org/repositories/home:/SilvioMoioli:/tools/openSUSE_Tumbleweed/home:SilvioMoioli:tools.repo
  sudo zypper install terraform-provider-libvirt
  git clone gitlab@gitlab.suse.de:mbologna/sumaform.git
  ```
- SUSE Linux Enterprise 12 SP1
  ```
  sudo zypper addrepo http://download.opensuse.org/repositories/home:/SilvioMoioli:/tools/SLE_12_SP1/home:SilvioMoioli:tools.repo
  sudo zypper install terraform-provider-libvirt
  git clone gitlab@gitlab.suse.de:mbologna/sumaform.git
  ```
- Ubuntu and Debian
  ```
  wget http://download.opensuse.org/repositories/home:/SilvioMoioli:/tools/SLE_12_SP1/x86_64/terraform.rpm
  sudo alien -i terraform.rpm
  wget http://download.opensuse.org/repositories/home:/SilvioMoioli:/tools/SLE_12_SP1/x86_64/terraform-provider-libvirt.rpm
  sudo alien -i terraform-provider-libvirt.rpm
  git clone gitlab@gitlab.suse.de:mbologna/sumaform.git
  ```

## Backend choice

`sumaform` can deploy virtual machines to:
 - single libvirt hosts
 - OpenStack private clouds
 - Amazon Web Services

At the moment the recommended backend for general development is the libvirt one.

The OpenStack backend was tested against the SUSE engineering private SUSE OpenStack Cloud installation only.

The Amazon Web Services backend has been developed for scalability tests and it is used in that context exclusively.

## Backend-specific configuration

Please refer to backend-specific guides:
 * [README-LIBVIRT.md](README-LIBVIRT.md)
 * [README-OPENSTACK.md](README-OPENSTACK.md)
 * [README-AWS.md](README-AWS.md)

## Typical use

### Run Terraform

Refer to the [official guides](https://www.terraform.io/docs/index.html) for a general understanding of Terraform and full commands.

For a very quick start:
```
terraform get # populates modules
terraform plan # show the provisioning plan
terraform apply # bring up your systems, fasten your seatbelts!
```

## Advanced use

### Create multiple hosts

Most resources support a `count` variable that allows you to create several instances at once. For example:

```
module "minionsles12sp1" {
  source = "./libvirt_host"
  name = "minionsles12sp1"
  image = "${module.images.sles12sp1}"
  server = "${module.suma3pg.hostname}"
  role = "minion"
  count = 10
}
```

This will create 10 minions connected to the suma3pg server.

### SUSE Manager Proxies

Create one SUSE Manager module, and a Proxy module with the `server` variable pointing at it. Then point clients to the proxy, as in the example below:

```
module "suma3pg" {
  source = "./libvirt_host"
  name = "suma3pg"
  memory = 4096
  vcpu = 2
  image = "${module.images.sles12sp1}"
  version = "3-nightly"
  database = "postgres"
  role = "suse-manager-server"
}

module "proxy3" {
  source = "./libvirt_host"
  name = "proxy3"
  image = "${module.images.sles12sp1}"
  server = "${module.suma3pg.hostname}"
  role = "suse-manager-proxy"
  version = "3-nightly"
}

module "clisles12sp1" {
  source = "./libvirt_host"
  name = "clisles12sp1"
  image = "${module.images.sles12sp1}"
  server = "${module.proxy3.hostname}"
  role = "client"
}
```

Note that proxy chains (proxies of proxies) work as expected.

### Inter-Server Sync (ISS)

Create two SUSE Manager server modules and add `iss-master` and `iss-slave` variable definitions to them, as in the example below:

```
module "suma21pgm" {
  source = "./libvirt_host"
  name = "suma21pgm"
  image = "${module.images.sles11sp3}"
  version = "2.1-stable"
  database = "postgres"
  role = "suse-manager-server"
  package-mirror = "${module.package_mirror.hostname}"
  iss-slave = "suma21pgs.tf.local"
}

module "suma21pgs" {
  source = "./libvirt_host"
  name = "suma21pgs"
  image = "${module.images.sles11sp3}"
  version = "2.1-stable"
  database = "postgres"
  role = "suse-manager-server"
  package-mirror = "${module.package_mirror.hostname}"
  iss-master = "${module.suma21pgm.hostname}"
}
```

Please note that `iss-master` is set from `suma21pg`'s module output variable hostname, while `iss-slave` is simply hardcoded. This is needed for terraform to resolve dependencies correctly, as dependency cycles are not permitted.
