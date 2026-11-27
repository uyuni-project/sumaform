# Re-diff: elbisna PoC base to the pin (#120)

Commands: `git diff --name-status -M 4a6614e6 d0c6e082 -- salt`, and the `variable` blocks of every
`variables.tf` under `modules/` and `backend_modules/` at both commits.

## Bases

- PoC base: `4a6614e6` (upstream merge of PR #2081 "update-gpg-keys"). Found in the PoC's `.git/logs/HEAD`
  (clone, first ansible commit on top of it, later a rebase onto `upstream/master`; the PoC's own
  reference to upstream is the `maximenoel8/sumaform` fork). The commit is an ancestor of the pin, so the
  merge-base is `4a6614e6` itself.
- Pin: `d0c6e082`. The pin is 546 commits ahead of the PoC base (the spec said 529; 546 is the measured
  count to the pin).
- The earlier state inventory read the old base, so any row sourced from it is stale where listed below.

## Salt tree, base to pin

156 paths changed: 26 added, 53 deleted, 68 modified, 9 renamed. The pin has 186 files under `salt/`.

| Area | Change |
|---|---|
| `server/` | all 30 files deleted (non-containerized server removed upstream) |
| `proxy/` | 3 files deleted (non-containerized proxy removed) |
| `client/` | 2 files deleted (client state removed); `top.sls` drops the `server`, `client`, `proxy` host roles |
| `repos/` | 9 deleted (server/proxy for 4.3, Uyuni and non-containerized, `client_tools_suma`), 8 renamed and 2 added: `server_containerized/` and `proxy_containerized/` directories with an `init.sls` each (`50` renamed to `52`), 16 modified |
| `scc/` | `client.sls`, `proxy.sls`, `server.sls` deleted |
| `server_containerized/` | 6 added (hub peripheral registration and certs, postgres, reposync wait, peripheral check), 1 renamed in from `server/`, 10 modified |
| `server_kubernetes/` | 7 added (additional disk, config, k8s systemd, SELinux policy, pgsql volume config, committed keypair), 1 deleted, 5 modified |
| `proxy_kubernetes/` | 4 added (two committed keypairs, cert and ingress yaml), 1 deleted (renamed yaml), 4 modified |
| `kubernetes_common/` | 4 install states deleted (helm, rke2, traefik, local-path provisioner), `kubernetes_dependencies.sls` added |
| `controller/` | `limits.conf`, `sysctl.conf` added, 4 modified |
| `rhel_container/` | new host role (3 files) with a `top.sls` entry |
| `default/` | 12 modified, no add or delete |
| `example_module/` | added |
| others | `mirror` (4), `jenkins` (2), `minion`, `build_host`, `locust`, `salt_testenv`, `proxy_containerized`, `_states`, `scc` (1), two top-level scripts: modified |

Host roles in the pin `top.sls`: server_containerized, server_kubernetes, proxy_containerized, proxy_kubernetes,
minion, rhel_container, mirror, controller, grafana, locust, virthost, build_host, jenkins, registry,
salt_testenv. Terraform also sets `sshminion`, `dhcp_dns`, `pxe_boot` (no state of their own; `dhcp_dns` is
provisioned from Terraform).

## Variables, base to pin

776 variable blocks at the base, 785 at the pin: 228 added, 219 removed.
Removed mostly with the non-containerized stack: `modules/server` (66), `modules/proxy` (31), `modules/client` (19),
`modules/rds` (11), `backend_modules/aws/db_host` (12), 47 from `controller`.
Added mostly in `controller` (77), `cucumber_testsuite` (36), `server_kubernetes` (30), `server_containerized` (20),
`build_validation` (20 + 23 + 7 in the two `bv_*` modules).

## Effect on the PoC (elbisna)

- PoC roles with no counterpart at the pin: `server`, `proxy`, `client` (Salt states deleted upstream). Their rows
  are not in the ledger; they would be `n/a-upstream-removed` and nothing at the pin cites them.
- PoC roles `server_install`, `proxy_install`: no Salt path of that name at the pin; the containerized install
  states (`install_mgradm.sls`, `install_podman.sls`, `install_common.sls`) are mapped to `containerized_common`.
- PoC has nothing for the new states (hub peripheral, `rhel_container`, kubernetes keys and charts); those are
  new work for the ported roles, not reuse.
- PoC claims were not used as input.
