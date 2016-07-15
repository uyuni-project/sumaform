# sumaform

![Sumicform, a green hedgehog made of bricks, sumaform's mascot](help/sumicform.png)

`sumaform` is a way to quickly configure test SUSE Manager setups with clients and servers.

It got its [portmanteau](https://en.wikipedia.org/wiki/Portmanteau) name being the successor of [suminator](https://github.com/SUSE/suminator/) implemented as [Terraform](https://www.terraform.io/) modules.

## Installation

 * install [Terraform](https://www.terraform.io/)
   * on SUSE distros, 1-click installers are available for [Leap](http://software.opensuse.org/ymp/Virtualization:containers/openSUSE_Leap_42.1/terraform.ymp?base=openSUSE%3ALeap%3A42.1&query=terraform), [Tumbleweed](http://software.opensuse.org/ymp/Virtualization:containers/openSUSE_Tumbleweed/terraform.ymp?base=openSUSE%3ATumbleweed&query=terraform) and  [SLE](http://software.opensuse.org/ymp/Virtualization:containers/SLE_12_SP1/terraform.ymp?base=SUSE%3ASLE-12%3AGA&query=terraform)
 * install [terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt)
   * on SUSE distros, 1-click installers are available for [Leap](http://software.opensuse.org/ymp/Virtualization:containers/openSUSE_Leap_42.1/terraform-provider-libvirt.ymp?base=openSUSE%3ALeap%3A42.1&query=terraform-provider-libvirt), [Tumbleweed](http://software.opensuse.org/ymp/Virtualization:containers/openSUSE_Tumbleweed/terraform-provider-libvirt.ymp?base=openSUSE%3ATumbleweed&query=terraform-provider-libvirt) and  [SLE](http://software.opensuse.org/ymp/Virtualization:containers/SLE_12_SP1/terraform-provider-libvirt.ymp?base=SUSE%3ASLE-12%3AGA&query=terraform-provider-libvirt)
 * clone this repo:
  ```
  git clone gitlab@gitlab.suse.de:mbologna/sumaform.git
  cd sumaform
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

## Run Terraform

Refer to the [official guides](https://www.terraform.io/docs/index.html) for a general understanding of Terraform and full commands.

For a very quick start:
```
terraform plan # show the provisioning plan
terraform apply # bring up your systems, fasten your seatbelts!
```

## Customize virtual machine hardware

You can add the following parameters to a `libvirt_host` module in `main.tf` to customize its virtual hardware:
 - `memory = <N>` to set the machine's RAM to N MiB
 - `vcpu = <N>` to set the number of virtual CPUs
