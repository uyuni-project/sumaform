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

`sumaform` can deploy either to single libvirt hosts or OpenStack clouds.

If you are using `sumaform` outside of the SUSE engineering network, for example on your laptop for demos, use the libvirt backend.

If you are using `sumaform` in the SUSE engineering network for development, please use the OpenStack backend.


## OpenStack-specific configuration

### Upload base images via Glance

Terraform does not have support for [OpenStack Glance](http://docs.openstack.org/developer/glance/).
This project contains a script to upload `suminator`-specific images to Glance:

* install the `glance` command on your distribution:
  * SLES and openSUSE:
  ```
  # replace <DISTRO> with SLE_12_SP2, openSUSE_Leap_42.1 or openSUSE_Tumbleweed
  zypper addrepo http://download.opensuse.org/repositories/Cloud:OpenStack:Master/<DISTRO>/Cloud:OpenStack:Master.repo
  zypper refresh
  zypper install python-glanceclient
  ```
  * Ubuntu:
  ```
  sudo apt install python-glanceclient
  ```
* customize and run `openstack_images/upload_images_to_glance.sh.example` to upload images to OpenStack through Glance.

### Set OpenStack variables

You need to export your OpenStack credentials as exported shell variables:

```
export OS_USERNAME=<OS_USERNAME>
export OS_PASSWORD=<OS_PASSWORD>
```

Other variables describing the tenant, URL and network ID will by default be asked interactively. You can set those in [environment variables or variable files](https://www.terraform.io/docs/configuration/variables.html#environment-variables) if you prefer.

### Create a `main.tf` file

Create a `main.tf` file by copying `main.tf.openstack.example`. Keep only hosts that you actually need, since all of them will be created by default once you run Terraform.

## libvirt-specific configuration

### Set libvirt variables

The default configuration expects a libvirt daemon listening on localhost, with a `default` storage pool and a NAT network called `vagrant-libvirt`. You can override all of these values with [environment variables or variable files](https://www.terraform.io/docs/configuration/variables.html#environment-variables) looking at defaults in `libvirt_host/variables.tf`.

### Create a `main.tf` file

Create a `main.tf` file by copying `main.tf.libvirt.example`. Keep only hosts that you actually need, since all of them will be created by default once you run Terraform.

## Typical use

### Run Terraform

Refer to the [official guides](https://www.terraform.io/docs/index.html) for a general understanding of Terraform and full commands.

For a very quick start:
```
terraform get # populates modules
terraform plan # show the provisioning plan
terraform apply # bring up your systems, fasten your seatbelts!
```

### Accessing the Virtual Machines

All machines come with avahi's mDNS configured by default on the `.tf.local` domain, and a `root` user with password `linux`. Provided your host is on the same network segment of the virtual machines you can access them via:

```
ssh root@suma3pg.tf.local
```

You can add the following lines to `~/.ssh/config` to avoid checking hosts and specifying a username:

```
Host *.tf.local
 StrictHostKeyChecking no
 UserKnownHostsFile=/dev/null
 User root
```

Web access is on standard ports, so `firefox suma3pg.tf.local` will work as expected.

## Advanced use

### Customize virtual machine hardware

You can add the following parameters to a `libvirt_host` module in `main.tf` to customize its virtual hardware:
 - `memory = <N>` to set the machine's RAM to N MiB
 - `vcpu = <N>` to set the number of virtual CPUs

### Update base OS images

 * OpenStack: re-run `upload_images_to_glance.sh`, taint all dependent disks and re-apply the plan:
```
 ./openstack_images/upload_images_to_glance.sh
terraform taint -module=suma3pg libvirt_volume.main_disk
...
terraform apply
```

 * libvirt: taint the VM disk(s) you want to update and re-apply the plan:
```
terraform taint -module=images libvirt_volume.sles12sp1
terraform apply
```
