# Build Validation module

The `build_validation` module deploys a full Build Validation (BV) environment: controller, server, proxy, monitoring, build hosts, and any number of minions across all supported OS families.

> **Note:** This module is designed to be used by the Multi-Linux Manager QE CI pipelines via [susemanager-ci](https://github.com/SUSE/susemanager-ci). If you are looking to deploy a standard test environment, see the [`cucumber_testsuite` module](README_TESTING.md) instead.

## Overview

Unlike other sumaform modules where each environment has its own `main.tf` with hardcoded values, the `build_validation` module uses a **single `main.tf`** shared across all BV environments. Environment-specific values — MAC addresses, hostnames, hypervisors, product versions — are provided entirely through a `terraform.tfvars` file that is assembled at pipeline runtime by susemanager-ci.

This separation means:

- Adding a new BV environment only requires a new `.tfvars` file in susemanager-ci — no changes to sumaform.
- Removing or adding a minion from an environment is done by adding or removing a key in the `.tfvars` file.
- The sumaform repository only needs to be updated when the **set of supported node types changes**.

## Dynamic resource creation

Each node in `main.tf` is guarded by a `count` expression that checks whether the corresponding key exists in the map from assembled tfvars (`ENVIRONMENT_CONFIGURATION`), bound in the module as `var.environment_configuration`:

```hcl
module "sles15sp7_minion" {
  count  = lookup(var.environment_configuration, "sles15sp7_minion", null) != null ? 1 : 0
  source = "../minion"

  name  = var.environment_configuration.sles15sp7_minion.name
  image = "sles15sp7o"
  provider_settings = {
    mac    = var.environment_configuration.sles15sp7_minion.mac
    memory = 4096
  }
  ...
}
```

If the key is absent from the tfvars file the module is not created (`count = 0`). If it is present it is deployed (`count = 1`). For modules where optional sub-fields may be absent (e.g. `server_containerized` which has an optional `string_registry` field), intermediate `locals` blocks are used to avoid Terraform errors when looking up missing keys.

## Input variables

The module receives variables populated from the assembled `terraform.tfvars`.

### `ENVIRONMENT_CONFIGURATION`

A map describing every node in the environment plus a few environment-wide settings. The **presence of a key** is what controls whether a node is deployed.

Assembled `terraform.tfvars` from susemanager-ci use the name `ENVIRONMENT_CONFIGURATION`. The sumaform module declares the Terraform variable `environment_configuration` (used as `var.environment_configuration` in [modules/build_validation/main.tf](modules/build_validation/main.tf)); the pipeline supplies the payload under the uppercase key expected by the root/wrapper configuration.

Required entries:

- `controller`
- one of `server` or `server_containerized`

Most nodes only require `mac` and `name`. Some have additional optional fields:

| Node type | Extra fields |
|---|---|
| `server_containerized`, `proxy_containerized` | `image` (base OS image), `string_registry` (bool) |
| `sles15sp5s390_minion`, `sles15sp5s390_sshminion` | `userid` (z/VM user ID) |
| `monitoring_server` | optional `image` override |

The map currently uses `name_prefix` as its BV-wide scalar. `product_version` is a separate module variable in `modules/build_validation/variables.tf`, and `url_prefix` is not consumed directly by the sumaform module.

A trimmed example (see susemanager-ci for full files like [head](https://github.com/SUSE/susemanager-ci/blob/master/terracumber_config/tf_files/tfvars/build-validation-tfvars/mlmhead_build_validation_nue.tfvars)):

```hcl
ENVIRONMENT_CONFIGURATION = {
  # Always present
  controller = {
    mac  = "xx:xx:xx:xx:xx:xx"
    name = "controller"
  }
  server_containerized = {
    mac             = "xx:xx:xx:xx:xx:xx"
    name            = "server"
    image           = "slemicro55o"
    string_registry = false
  }
  proxy_containerized = {
    mac             = "xx:xx:xx:xx:xx:xx"
    name            = "proxy"
    image           = "slemicro55o"
    string_registry = false
  }

  # Optional — omit any key to skip deploying that node
  sles15sp7_minion = {
    mac  = "xx:xx:xx:xx:xx:xx"
    name = "sles15sp7-minion"
  }
  rocky8_minion = {
    mac  = "xx:xx:xx:xx:xx:xx"
    name = "rocky8-minion"
  }
  alma10_minion = {
    mac  = "xx:xx:xx:xx:xx:xx"
    name = "alma10-minion"
  }
  oracle10_minion = {
    mac  = "xx:xx:xx:xx:xx:xx"
    name = "oracle10-minion"
  }
  rocky10_minion = {
    mac  = "xx:xx:xx:xx:xx:xx"
    name = "rocky10-minion"
  }
  ubuntu2404_sshminion = {
    mac  = "xx:xx:xx:xx:xx:xx"
    name = "ubuntu2404-sshminion"
  }

  # s390x nodes require an extra userid field
  sles15sp5s390_minion = {
    mac    = "xx:xx:xx:xx:xx:xx"
    name   = "sles15sp5s390-minion"
    userid = "SxxMINUE"
  }

  product_version = "x.x-released"
  name_prefix     = "suma-bv-xx-micro-"
  url_prefix      = "https://ci.suse.de/view/Manager/view/Manager-qe/job/manager-x.x-micro-qe-build-validation"
}
```

### Deployable node keys

Which nodes can be toggled is defined by `lookup(var.environment_configuration, "<key>", null)` (and related patterns) in [modules/build_validation/main.tf](modules/build_validation/main.tf). That file is the authoritative list of keys; adding or removing a node type is done there. Variable shape is declared in [modules/build_validation/variables.tf](modules/build_validation/variables.tf).

Some SLE Micro / SL Micro `*_sshminion` modules exist only as commented-out workarounds in [modules/build_validation/main.tf](modules/build_validation/main.tf) and are not deployable in BV until uncommented.

**Special notes**

- `salt_migration_minion` is a dedicated SLES 15 SP5 minion used to test migration from OS Salt to Salt bundle and is deployed with `install_salt_bundle = false`.
- `slemicro52_minion`, `slemicro53_minion`, and `slemicro54_minion` are kept with `install_salt_bundle = false` because of the in-file workaround comment.
- `opensuse156arm_*` and `opensuse160arm_*` get their location-specific extension and FQDN handling from the module code.
- `opensuse160arm_minion` and `opensuse160arm_sshminion` currently use `./salt/controller/id_ed25519.pub` directly for `ssh_key_path` in the module code.

### `BASE_CONFIGURATIONS`

A map of hypervisor connection details. The number of entries depends on the deployment site.

Assembled tfvars use `BASE_CONFIGURATIONS`. The sumaform module declares `base_configurations` (and derives `module_base_configurations` internally from that input); see [modules/build_validation/variables.tf](modules/build_validation/variables.tf).

- **Single-provider sites** (e.g. Nuremberg/Prague): one `base_core` entry, plus architecture-specific entries like `base_arm` if ARM nodes are present.
- **Multi-provider sites** (e.g. SLC/backup): one entry per hypervisor, allowing VMs to be distributed across machines.

```hcl
# Single-provider (Nuremberg)
BASE_CONFIGURATIONS = {
  base_core = {
    pool               = "ssd"
    bridge             = "br0"
    additional_network = "192.168.xx.0/24"
    hypervisor         = "suma-xx.mgr.suse.de"
  }
  base_arm = {
    pool               = "ssd"
    bridge             = "brx"
    additional_network = null
    hypervisor         = "suma-arm.mgr.suse.de"
  }
}

# Multi-provider (SLC) — one entry per hypervisor
BASE_CONFIGURATIONS = {
  base_core_1 = {
    pool               = "ssd"
    bridge             = "br1"
    additional_network = "192.168.xx.0/24"
    hypervisor         = "suma-slc-xx.mgr.suse.de"
  }
  base_core_2 = {
    pool               = "ssd"
    bridge             = "brx"
    additional_network = "192.168.xx.0/24"
    hypervisor         = "suma-slc-xx.mgr.suse.de"
  }
}
```

## Provider wrappers

Because the libvirt provider requires explicit aliases for each hypervisor, `main.tf` does not declare providers directly. Instead, the pipeline passes one of two **wrapper template files** from susemanager-ci as the Terraform entry point. The `main.tf` itself is provider-agnostic.

**`build-validation-single-provider.tf`** — for sites with one hypervisor. Declares a single provider and passes it to the module.

**`build-validation-multi-providers.tf`** — for sites with multiple hypervisors. Declares one provider block per hypervisor using aliases, then maps each alias to the corresponding `BASE_CONFIGURATIONS` entry in the module.

## Variable declarations

Variable type definitions for the upstream `ENVIRONMENT_CONFIGURATION` and `BASE_CONFIGURATIONS` aliases live in susemanager-ci:

```
susemanager-ci/terracumber_config/tf_files/variables/build-validation-variables.tf
```

This file is passed to Terraform alongside the tfvars file and the wrapper template.

## Relationship to susemanager-ci

All environment-specific configuration is stored in susemanager-ci. Before deploying, the Jenkins pipeline runs `prepare_tfvars.py` to assemble the final `terraform.tfvars` from the static per-environment tfvars file, `location.tfvars`, and dynamic values injected from Jenkins (container repositories, Cucumber branch, product version overrides, etc.).

See the [susemanager-ci terracumber_config README](https://github.com/SUSE/susemanager-ci/blob/master/terracumber_config/README.md) for the full picture of how configuration flows from susemanager-ci into this module.
