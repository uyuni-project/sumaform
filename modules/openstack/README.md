# OpenStack-specific configuration

## First-time configuration

 - get OpenStack credentials
 - copy `main.tf.openstack.example` to `main.tf`
 - either:
   - complete connection details in the `provider` block of the `main.tf` file, or
   - download a credentials file from the "Access and Security" panel, and source it from your favorite shell (this will set credentials in environment variables):
      ```bash
      firefox https://<ADMIN_NODE>/project/access_and_security/api_access/openrc/
      source ./<PROJECT>-openrc.sh
      ```
 - complete the `cc_password` variable in the `base` module
 - if you are using the SUSE-internal "ECP" Cloud instance, make sure to uncomment relevant lines in `base`
 - otherwise, if other sumaform users deploy to the same Cloud instance, consider uncommenting at least the `name_prefix` variable declaration in the `base` module to specify a unique prefix for your VMs
 - decide the set of virtual machines you want to run. Delete any `module` section relative to VMs you don't want to use and feel free to copy and paste to add more
 - run `terraform init` to make sure Terraform has detected all modules
 - run `terraform plan` to see what Terraform is about to do
 - run `terraform apply` to actually have the VMs set up!

## Accessing VMs

All machines come with avahi's mDNS configured by default on the `.tf.local` domain, and user `root` with password `linux` accessible via your SSH public key (by default `~/.ssh/id_rsa.pub`).

Thus if your host is on the same network segment of the virtual machines you can simply use:
```
ssh root@susemanager-suma31pg.tf.local
```

Otherwise, you can look in the OpenStack admin Web UI for the floating IPs.

If you want to use a different SSH key, or mDNS does not work out of the box, or if you don't want to use mDNS, please check the README_ADVANCED.md and TROUBLESHOOTING.md files.

Web access is on standard ports, so `firefox <IP_HOST>` will work as expected. SUSE Manager default user is `admin` with password `admin`.

## Customize virtual hardware

Most modules expose a `flavor` variable you can use to change the virtual hardware to another flavor as defined in the Cloud instance, and many also expose a `extra_volume_size` to add storage space if needed. In the current implementation, all root volumes are created locally, and extra volumes are in Cinder.
