# Smoke subset TODO (user-run, level 3)

Nothing below has been run: no deploy, no evidence. Each item names what to run and what to look at; record the result as a
`ansible/ledger/runs/<id>.json` run and use `ansible/ledger/propose.py` for the `verified` entries. Libvirt only, a dev
environment, `provisioner = "ansible"`, one deployment per group. Check the second apply (zero changed tasks) only on the
roles marked "re-run"; the other roles are known not to be clean (see the `ponytail:` comments).

## Long tail (#127)

- mirror: deploy with `nfs_server` default and `synchronize_immediately = false`. Check `/srv/mirror` is a mounted
  partition (owner wwwrun, mode 777), `systemctl is-active apache2 nfs-ganesha cron`, `/etc/minima.yaml` carries the SCC
  user, `/etc/cron.daily/` has the four symlinks. Then once with `disable_cron = true` (no cron package, no links) and once
  with `customize_minima_file = "mirror/etc/minimum_repositories_testsuite.yaml"` (the file is that template).
- jenkins: `/var/lib/jenkins` mounted from the data disk, jenkins and apache2 active, `curl http://<host>/` answers,
  `/var/lib/jenkins/plugins/swarm.jpi` exists, podman container `http_proxy` runs as user podman (`runuser -u podman -- podman ps`).
- grafana: needs a server and (optionally) a locust host in the deployment. Open `http://<host>/`: anonymous admin login,
  Prometheus datasource and the dashboard are there, the home dashboard is set (the uri call replaces the Python 2 script).
  `systemctl is-active prometheus grafana-server`; re-run.
- registry: `curl http://<host>/v2/_catalog` answers, `systemctl is-active registry`; re-run.
- locust: master plus one slave. `systemctl is-active locust locust_exporter`, `curl localhost:9500` on the master, the slave
  shows up in the master.
- salt_testenv: on SLES 15, Leap and SL Micro (flavor `saltstack:products:testing`). The repositories exist,
  `rpm -q python3-salt-testsuite venv-salt-minion-testsuite docker`, docker active. On SL Micro: the snapshot is active
  after the reboot step, `/opt/salt-testsuite-classic` and `/opt/salt-testsuite-bundle` exist.
- virthost: libvirtd (not the modular daemons) active, `systemd-detect-virt` prints `none`, `br0` is up, with
  `hvm_disk_image` set: `/var/testsuite-data/<os>-disk-image-template.qcow2` and `cloudinit-disk-<os>.iso` exist; the host
  rebooted once into the new kernel and does not reboot on the second apply; the minion host role is still configured (re-run).
- rhel_container: with `rhel_version` 9: image `ubi9-ssh` built, `ubi9-client` active, ssh to the container port (2222) works
  with the authorized key.
- server_kubernetes and proxy_kubernetes: with per-deployment keys supplied (see "Before the kubernetes smoke"). Check
  `/etc/rancher/rke2/config.yaml`, `/etc/profile.d/rke2_vars.sh`, `/root/helm-charts/selfsigned/{Chart,values}.yaml`, the
  ingress manifest, `/etc/profile.d/server_kubernetes_vars.sh` is mode 0600; on the proxy, `ssh <server>` works with no password
  and the proxy variables file reached the server. Then let the testsuite install RKE2 and the charts (the real proof).
  On Tumbleweed or SL Micro 6.2 also: `semodule -l | grep uyuni_container`; on SLES 15.7 or Ubuntu: the AppArmor profile is loaded.
- dhcp_dns and pxe_boot: nothing to run on the host (`provision = false`, Terraform-driven). Check a `tofu plan` with
  `provisioner = "ansible"` and these modules passes the plan-time precondition.
- data_disk (mirror and jenkins): covered by their items; on an `nvme` data disk check the `p1` partition name.

## Before the kubernetes smoke (user decision, open since #126)

`peer_public_keys`, `ssh_private_key` and `ssh_public_key` are read from host vars but the Terraform handoff does not
generate them yet (`backend_modules/libvirt/host/main.tf`, `TODO(#126)`). The kubernetes roles stop at the keypair task
until that exists, like the containerized server and proxy.

## Leftovers recorded for earlier roles (from the code, no commit message holds any)

- Containerized server and proxy (#126): the keypair and `peer_public_keys` above; the cloned channels step runs
  `spacewalk-utils` inside the server container, which must ship it (`cloned_channels.yml`); the proxy install has no
  already-installed guard, so a second apply is not clean (`proxy_containerized/tasks/install.yml`); the large deployment
  and cobbler `sed` steps do not detect changes (`large_deployment.yml`, `testsuite.yml`); initial content steps report
  unchanged when they cannot tell (`initial_content.yml`).
- Controller (#125): `install_kubernetes_server_on_external_cluster` is still refused by `controller_system`; porting it
  needs the kubernetes roles above run from the controller (deferred, not part of this ticket).
- Reboot backbone (#123, spec seam 2): deploy plus second apply with zero changed tasks on SLE Micro, SL Micro and
  SLES 16, and the old-snapshot rejection. The worker preflight (#118, `ansible/worker/preflight.sh`) on each worker.
