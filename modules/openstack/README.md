# OpenStack-specific configuration

## This project is under development, it might be that some docu and functionality has changed.


## Upload base images via Glance

Terraform does not have support for [OpenStack Glance](http://docs.openstack.org/developer/glance/).
This project contains a script to upload `sumaform`-specific images to Glance:

* install the `glance` command on your distribution:
  * SLES and openSUSE:
  ```
  # replace <DISTRO> with SLE_12_SP3, openSUSE_Leap_42.3 or openSUSE_Tumbleweed
  zypper addrepo http://download.opensuse.org/repositories/Cloud:OpenStack:Master/<DISTRO>/Cloud:OpenStack:Master.repo
  zypper refresh
  zypper install python-glanceclient
  ```
  * Ubuntu:
  ```
  sudo apt install python-glanceclient
  ```
* customize and run `modules/openstack/images/upload_images_to_glance.sh.example` to upload images to OpenStack through Glance.

## Set OpenStack variables

You need to export your OpenStack credentials as exported shell variables:

```
export OS_USERNAME=<OS_USERNAME>
export OS_PASSWORD=<OS_PASSWORD>
```

Other variables describing the tenant, URL and network ID will by default be asked interactively. You can set those in [environment variables or variable files](https://www.terraform.io/docs/configuration/variables.html#environment-variables) if you prefer.

## Create a `main.tf` file

Create a `main.tf` file by copying `main.tf.openstack.example`. Keep only hosts that you actually need, since all of them will be created by default once you run Terraform.

## Accessing the Virtual Machines

All machines come with avahi's mDNS configured by default on the `.tf.local` domain, and a `root` user with password `linux`. Provided your host is on the same network segment of the virtual machines you can access them via:

```
ssh root@suma-head-srv.tf.local
```

You can add the following lines to `~/.ssh/config` to avoid checking hosts and specifying a username:

```
Host *.tf.local
 StrictHostKeyChecking no
 UserKnownHostsFile=/dev/null
 User root
```

Web access is on standard ports, so `firefox suma-head-srv.tf.local ` will work as expected.
