# libvirt-specific configuration

## First-time configuration

 - copy `main.tf.libvirt.example` to `main.tf`
 - if your VMs are to be deployed on an external libvirt host:
   - change the libvirt connection URI in the `provider` section. Typically it has the form `qemu+ssh://<USER>@<HOST>/system` assuming that `<USER>` has passwordless SSH access to `<HOST>`
   - set up bridged networking:
     - ensure your target libvirt host has a bridge device on the network you want to expose your machines on ([openSUSE instructions](https://doc.opensuse.org/documentation/leap/virtualization/html/book.virt/cha-libvirt-networks.html#libvirt-networks-bridged) [Ubuntu instructions](https://help.ubuntu.com/community/NetworkConnectionBridge))
     - uncomment the `bridge` variable declaration in the `base` module and add proper device name (eg. `br1`)
     - set the `network_name` variable declaration to `null` or remove it
     - optionally specify fixed MAC addresses by adding `mac = "CA:FE:BA:BE:00:01"` lines to VM modules
   - if other sumaform users deploy to the same host, or different bridged hosts in the same network, uncomment the `name_prefix` variable declaration in the `base` module to specify a unique prefix for your VMs
 - complete the `cc_password` variable in the `base` module
 - make sure that:
   - either your target libvirt host has a storage pool named `default`
   - or you [create one](https://documentation.suse.com/sles/12-SP4/html/SLES-all/cha-libvirt-storage.html#sec-libvirt-storage-vmm-addpool)
   - or you specify a different name by uncommenting the `pool` variable declaration in the `base` module
 - if you are not using bridged networking, make sure that:
   - either your target libvirt host has a NAT network which is named `default`
   - or you [create one](https://documentation.suse.com/sles/12-SP4/html/SLES-all/cha-libvirt-networks.html#libvirt-networks-virtual-vmm-define)
     - Note: ipv6 is configured by default on all VMs created by sumaform, so make sure to enable ipv6 too (DHCPv6 is not necessary)
   - or you specify a different name by uncommenting the `network_name` variable declaration in the `base` module
 - decide the set of virtual machines you want to run. Delete any `module` section relative to VMs you don't want to use and feel free to copy and paste to add more
 - Create a symbolic link to the `libvirt` backend module directory inside the `modules` directory: `cd modules && ln -sfn ../backend_modules/libvirt backend`
 - run `terraform init` to make sure Terraform has detected all modules
 - run `terraform apply` to actually have the VMs set up!

## libvirt backend specific variables

Most modules have configuration settings specific to the libvirt backend, those are set via the `provider_settings` map variable. They are all described below.

### Base module

Available provider settings for the base module:

| Variable name      | Type   | Default value | Description                                                              |
|--------------------|--------|---------------|--------------------------------------------------------------------------|
| pool               | string | `default`     | libvirt storage pool name for VM disks                                   |
| network_name       | string | `default`     | libvirt NAT network name for VMs, use null for bridged networking        |
| bridge             | string | `null`        | a bridge device name available on the libvirt host, leave null for NAT   |
| additional_network | string | `null`        | A network mask for PXE tests                                             |

An example follows:
```hcl-terraform
...
provider_settings = {
  pool               = "ssd"
  network_name       = "my_network"
  bridge             = "br1"
  additional_network = "192.168.32.0/24"
}
...
```

### Host modules

Following settings apply to all modules that create one or more hosts of the same kind, such as `suse_manager`, `suse_manager_proxy`, `client`, `grafana`, `minion`, `mirror`, `sshminion`, `pxe_boot` and `virthost`:

| Variable name   | Type           | Default value                                                | Description                                                                                |
|-----------------|----------------|--------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| memory          | number         | `1024` ([apart from specific roles](Default-values-by-role)) | RAM memory in MiB                                                                          |
| vcpu            | number         | `1` ([apart from specific roles](Default-values-by-role))    | Number of virtual CPUs                                                                     |
| running         | bool           | `true`                                                       | Whether this host should be turned on or off                                               |
| mac             | string         | `null`                                                       | A MAC address in the form AA:BB:CC:11:22:22                                                |
| cpu_model       | string         | `custom`                                                     | Defines what CPU model the guest is getting (host-model, host-passthrough or the default). |
| xslt            | string         | `null` ([apart from specific roles](Default-values-by-role)) | XSLT contents to apply on the libvirt domain                                               |

An example follows:
```hcl-terraform
...
provider_settings = {
  memory          = 2048
  vcpu            = 2
  running         = true
  mac             = "52:54:00:1d:af:5a"
  cpu_model       = "custom"
  xslt            = "file.xslt"
}
...
```

`suse_manager`, `proxy` and `mirror` modules have configuration settings specific for extra data volumes, those are set via the `volume_provider_settings` map variable. They are described below.

 * `pool = <String>` storage were the volume should be created (default value `default`)

 An example follows:
 ``` hcl-terraform
volume_provider_settings = {
  pool = "ssd"
}
```

#### Default provider settings by role

Some roles such as `suse_manager` or `mirror` have specific defaults that override those in the table above. Those are:

| Role         | Default values                                                                               |
|--------------|----------------------------------------------------------------------------------------------|
| suse_manager | `{memory=4096, vcpu=2}`                                                                      |
| mirror       | `{memory=512}`                                                                               |
| controller   | `{memory=2048}`                                                                              |
| grafana      | `{memory=4096}`                                                                              |
| virthost     | `{memory=2048, vcpu=3, cpu_model = "host-passthrough", xslt = file("${path.module}/sysinfos.xsl"}` |

## Accessing VMs

All machines come with user `root` with password `linux`. They are also accessible via your SSH public key (by default `~/.ssh/id_rsa.pub`) if you have one.

By default, the machines use Avahi (mDNS), and are configured on the `.tf.local` domain. Thus if your host is on the same network segment of the virtual machines you can simply use:

```
ssh root@suma32pg.tf.local
```

If you use Avahi and are on another network segment, you can only connect using an IP address, because mDNS packets do not cross network boundaries unless using reflectors.

If you want to use a different SSH key, please check the README_ADVANCED.md file, in section "Custom SSH keys".
If you don't want to use mDNS, or want to forward Avahi between networks, please check that same file, in section "Disabling Avahi and Avahi reflectors".
If mDNS does not work out of the box, please check TROUBLESHOOTING.md file, under question "How can I work around name resolution problems with `tf.local` mDNS/Zeroconf/Bonjour/Avahi names?".

Web access is on standard ports, so `firefox server.tf.local` will work as expected. SUSE Manager default user is `admin` with password `admin`.

Finally, the images come with serial console support, so you can use

```
virsh console suma32pg
```
especially in the case the network is not working and you need to debug it, or if the images have difficulties booting.

## Only upload a subset of available images

By default all known base OS images are uploaded to the libvirt host (currently several versions of SLES and CentOS). It is possible to limit the OS selection in order to avoid wasting space and bandwidth, if the needed OSs are known a priori.

In order to do that use the `images` variable in the `base` module, like in the following example:

```hcl
module "base" {
  source = "./modules/base"

  ...
  images = ["centos7", "sles12sp2"]
}
```

The list of all supported images is available in "backend_modules/libvirt/base/variables.tf".


## DNS and DHCP without Avahi

If you do not want or cannot use Avahi (e. g. Windows minions), the easiest DHCP and DNS alternative is libvirt's own dnsmasq.

First thing you need to do is tell sumaform to not use Avahi in `main.tf`:

```hcl
module "base" {
  source = "./modules/base"

  ...
  use_avahi = false
```


### Configuring the libvirt network

If you are using the `default`virtual network in the 192.168.122.1 network, you will have this interface:

```
$ sudo virsh net-list --all
 Name                 State      Autostart     Persistent
----------------------------------------------------------
 default              active     yes           yes
```

You can edit the XML with virt-manager (do not forget to stop the interface before making changes, or they will be lost!) or with virsh:

```
$ sudo virsh net-edit default
```

It will look like this:

```xml
<network connections="3">
  <name>default</name>
  <uuid>366c6da3-f7e3-413c-93ca-c4c89ef02ac4</uuid>
  <forward mode="nat">
    <nat>
      <port start="1024" end="65535" />
    </nat>
  </forward>
  <bridge name="virbr0" stp="on" delay="0" />
  <mac address="52:54:00:78:04:82" />
  <ip address="192.168.122.1" netmask="255.255.255.0">
    <dhcp>
      <range start="192.168.122.2" end="192.168.122.254" />
    </dhcp>
  </ip>
</network>
```

You can now add the MACs and desired IPs in the `ip` block, below the `range` entry. Please note I have changed the range start address to allocate space for static address leases. Your XML will look like this:

```xml
<ip address="192.168.122.1" netmask="255.255.255.0">
  <dhcp>
    <range start="192.168.122.10" end="192.168.122.254" />
      <host mac="52:54:00:09:af:bf" ip="192.168.122.2" />
      <host mac="52:54:00:76:78:dc" ip="192.168.122.3" />
      <host mac="52:54:00:90:15:99" ip="192.168.122.4" />
  </dhcp>
</ip>
```

We could add the hostnames to the XML too but in that case, name resolution would only work across virtual guest. As we want name resolution to work also between host and guest, we will now add the domain name to the libvirt network XML, right after the `mac address` block:

```xml
<domain name="suse.lab" localOnly="yes" />
```

In the end, your XML will look like this:

```xml
<network connections="3">
  <name>default</name>
  <uuid>366c6da3-f7e3-413c-93ca-c4c89ef02ac4</uuid>
  <forward mode="nat">
    <nat>
      <port start="1024" end="65535" />
    </nat>
  </forward>
  <bridge name="virbr0" stp="on" delay="0" />
  <mac address="52:54:00:78:04:82" />
  <domain name="suse.lab" localOnly="yes" />
  <ip address="192.168.122.1" netmask="255.255.255.0">
    <dhcp>
      <range start="192.168.122.10" end="192.168.122.254" />
        <host mac="52:54:00:09:af:bf" ip="192.168.122.2" />
        <host mac="52:54:00:76:78:dc" ip="192.168.122.3" />
        <host mac="52:54:00:90:15:99" ip="192.168.122.4" />
    </dhcp>
  </ip>
</network>
```

Also, add the desired domain name to `main.tf`:

```hcl
module "base" {
  source = "./modules/base"

  ...
  use_avahi = false
  domain = "suse.lab"
```

Now edit `/etc/hosts` on the host machine and add your guests:

```
192.168.122.2 uyuniserver.suse.lab
192.168.122.3 leap151.suse.lab
192.168.122.4 win10.suse.lab
```

Finally, destroy and start again your libvirt network:

```
$ sudo virsh net-destroy default && sudo virsh net-start default
```

### Host network configuration

#### Identify the network management backend

These days most Linux distributions are using Network Manager for configuration and management of network interfaces, so you should go for the "Configuring NetworkManager" section below.

In case you want to double check whether you are using Network Manager or something else (e. g. wicked, networkd, etc), check for the service status:

```
$ sudo systemctl status NetworkManager
● NetworkManager.service - Network Manager
Loaded: loaded (/usr/lib/systemd/system/NetworkManager.service; enabled; vendor preset: disabled)
Drop-In: /usr/lib/systemd/system/NetworkManager.service.d
└─NetworkManager-ovs.conf
Active: active (running)
```

or in case you are not running systemd:

```
$ sudo service NetworkManager status
* NetworkManager.service - Network Manager
Loaded: loaded (/usr/lib/systemd/system/NetworkManager.service; enabled; vendor preset: disabled)
Drop-In: /usr/lib/systemd/system/NetworkManager.service.d
`-NetworkManager-ovs.conf
```

Some other query command may be required if you are running another operating system (e. g. BSD, MacOS, Windows) or init system (e. g. OpenRC, System V, etc).


#### Configuring NetworkManager

If you are using NetworkManager on the host machine, tell it to control dnsmasq:

```
$ sudo vi /etc/NetworkManager/conf.d/localdns.conf
[main]
plugins=keyfile
dns=dnsmasq
```

But only for the `suse.lab` domain:

```
$ sudo vi /etc/NetworkManager/dnsmasq.d/libvirt_dnsmasq.conf
server=/suse.lab/192.168.122.1
```

#### Alternative: no NetworkManager

If you are not using NetworkManager or do not want dnsmasq to be controlled by NetworkManager, use this configuration:

```
$ sudo vi /etc/NetworkManager/NetworkManager.conf
[main]
plugins=keyfile
dns=none
```

Tell your local dnsmasq to manage only `suse.lab`:

```
$ sudo vi /etc/dnsmasq.conf
listen-address=127.0.0.1
interface=lo
bind-interfaces
server=<yourUpstreamDNS>
log-queries

# does not go upstream to resolve addresses ending in 'suse.lab'
local=/suse.lab/
```

And add localhost to your /etc/resolv.conf:

```
$ sudo vi /etc/resolv.conf
# This should be the first nameserver entry in resolv.conf!
nameserver 127.0.0.1
```


### Finalize and test everything works as expected

Finally, restart all services: libvirtd, dnsmasq and NetworkManager:

```
$ sudo systemctl restart NetworkManager.service NetworkManager-dispatcher.service dnsmasq.service libvirtd.service libvirt-guests.service
```

And test name resolution from the host:

```
$ nslookup uyuniserver.suse.lab 127.0.0.1
Server:         127.0.0.1
Address:        127.0.0.1#53

Name:   uyuniserver.suse.lab
Address: 127.0.0.1

$ nslookup uyuniserver.suse.lab 192.168.122.1
Server:         192.168.122.1
Address:        192.168.122.1#53

Name:   uyuniserver.suse.lab
Address: 192.168.122.2

$ nslookup 192.168.122.2 192.168.122.1
2.122.168.192.in-addr.arpa      name = uyuniserver.suse.lab.
```

and from the guests:

```
$ nslookup uyuniserver.suse.lab 192.168.122.1
Server:         192.168.122.1
Address:        192.168.122.1#53

Name:   uyuniserver.suse.lab
Address: 192.168.122.2

$ nslookup 192.168.122.2 192.168.122.1
2.122.168.192.in-addr.arpa      name = uyuniserver.suse.lab.
```
