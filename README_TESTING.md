# Cucumber testsuite

## Basic deployment

It is possible to run [the Cucumber testsuite](https://github.com/uyuni-project/uyuni/tree/master/testsuite)  for SUSE Manager and Uyuni by using the `cucumber_testsuite` module. A libvirt example follows:

```hcl
provider "libvirt" {
  uri = "qemu:///system"
}

module "cucumber_testsuite" {
  source = "./modules/cucumber_testsuite"

  product_version = "4.3-nightly"

  cc_username = ...
  cc_password = ...

  cc_ptf_username = ...
  cc_ptf_password = ...

  name_prefix = "moio-"
  domain = "tf.local"
  git_username = ...
  git_password = ...

  provider_settings = {
    network_name = "default"
  }
}
```

This will create a test server, client and minion instances, plus a coordination node called a `controller` which runs the testsuite.

The example will have to be completed with SCC credentials and GitHub credentials to the SUSE Manager or Uyuni repo.
PTF SCC variables should only be used with SUSE Manager or Multi-Linux Manager versions later than 5.0.

`product_version` determines the version under test, see [README_ADVANCED.md](README_ADVANCED.md) for the list of options.

## Getting outputs

By default, the `cucumber_testsuite` module will not produce any outputs for the resources (for example the hostname for the instances).

If you want them, add the following to the end of your `main.tf` file:

```hcl
output "configuration" {
  value = module.cucumber_testsuite.configuration
}
```

That will generate the outputs on-screen and will store them in the `terraform.tfstate` file.

## Running the testsuite

To start the testsuite, use:

```bash
ssh -t head-ctl.tf.local run-testsuite
```

By default, `run-testsuite` runs over a selection of the YAML files in `run_sets`, i.e.:
`sanity_check.yml`, `core.yml`, `reposync.yml`, `init_clients.yml`, `secondary.yml`, `secondary_parallelizable.yml`, `finishing.yml`.

To enable/disable features, edit these YAML files. Keep in mind that:

- features prefixed with `core_` are essential for others to work, cannot be repeated and must be executed in the order given by `testsuite.yml`
- features not prefixed with `core_` are idempotent, so they can be run multiple times without changing test results.

Once all `core_` features have been executed you can run a non-core Cucumber feature as follows:

```bash
ssh root@head-ctl.tf.local
cd spacewalk/testsuite
cucumber -r features features/secondary/my_feature.feature
```

or an individual scenario with:

```bash
ssh root@head-ctl.tf.local
cd spacewalk/testsuite
cucumber -n "My nice scenario title"
```

Read HTML results at:

 `head-ctl.tf.local/output.html`. There is an additional running service, enabled during the `highstate`, on the `controller` which is exposing the entire `/root/spacewalk/testsuite` folder: all testsuite files, including results saved under this folder, are readable through the `http` protocol at the port `80`.

Get HTML results with:

```bash
scp head-ctl.tf.local://root/spacewalk-testsuite-base/output.html .
```

To keep the testsuite running after ending the ssh session using `screen` tool:

```bash
ssh -t head-ctl.tf.local screen run-testsuite
```

You can detach from the session at anytime using the key sequence `^A d`. To re-attach to the existing session:

```bash
ssh -t head-ctl.tf.local screen -r
```

## Running the package download benchmark

The package download benchmark starts from the Sumaform controller and targets
traditional Salt minions managed by Uyuni. It works with the existing managed
and external Kubernetes cluster modes. This benchmark entry point does not add
cluster lifecycle management: applying Sumaform can perform the deployment
selected by those existing modes, but running the benchmark does not provision
the cluster, deploy Uyuni, provision or onboard minions, synchronize
repositories, subscribe systems to channels, or select packages. Before running
it:

- provision the minions, register them with Uyuni, and subscribe them to channels
  that contain the requested packages;
- synchronize the required channel content before the benchmark;
- provide each package as an exact `[name, arch, evr]` tuple that is installable
  on every selected minion;
- set `install_kubectl_helm = true` and provide `kubeconfig_path` so the
  controller can access the cluster;
- deploy exactly one Ready Uyuni server pod in the `uyuni` namespace with the
  `app.kubernetes.io/component=server` label and an `uyuni` container.

For this benchmark, the `cucumber_testsuite` module supports provisioning
multiple `suse_minion` hosts with the libvirt backend:

```hcl
host_settings = {
  suse_minion = {
    quantity = 10
  }
}
```

`quantity` defaults to one when `suse_minion` is present. Sumaform exports all
generated minion hostnames as a JSON array in `UYUNI_BENCH_MINIONS`; the
existing `MINION` variable remains the first hostname for compatibility. The
quantity-to-Salt-ID mapping used by this benchmark is currently validated only
with libvirt.

The storage class is optional result metadata, not a benchmark dependency. On
the controller, provide the exact arbitrary StorageClass name when comparing
storage backends, provide the exact package tuples as JSON, and start only the
benchmark runset:

```bash
export UYUNI_BENCH_STORAGE_CLASS="example-storage-class"
export UYUNI_BENCH_PACKAGES='[
  ["rclone","x86_64","0:1.74.1-bp156.2.9.1"],
  ["restic","x86_64","0:0.18.0-bp156.2.6.1"]
]'
run-testsuite package-download-benchmark
```

For managed Kubernetes deployments, Sumaform exports the effective
`server_kubernetes.kubernetes_storage_class` value, including the `local-path`
default. For external clusters, it exports only an explicitly configured
StorageClass; it does not infer a class from the managed-cluster backend
default. An explicit shell value still overrides the metadata for a run. If an
external cluster uses its default StorageClass without an explicit name in
Sumaform, set the metadata value manually.

For an explicitly selected set of already managed traditional minions, override
the generated value with exact Salt IDs:

```bash
export UYUNI_BENCH_MINIONS='["minion-1.tf.local","minion-2.tf.local"]'
```

Both JSON arrays must be non-empty. The benchmark feature validates their
structure before changing client caches. The runner clears `PROFILE`, `TAGS`,
`CUCUMBER_OPTS`, and `FEATURE`, then executes only the
`kubernetes_package_download_benchmark` runset; it does not run the normal setup
or repository synchronization stages.

## Using Salt Bundle (venv-salt-minion) in "Head" and "Uyuni"

Currently, our `head` and `uyuni-master` testing deployments require the Salt Bundle (`venv-salt-minion` package) to be installed on each client instance and some other tunings, before the testsuite is started. Also, bear in mind that the `head` setup requires a containerized setup - use `server_containerized` and `proxy_containerized` modules (refer to the `main.tf.libvirt-testsuite.example` file to see how to configure this). To be sure that all necessary adjustments are in place for the testsuite to run for HEAD or Uyuni, you need to set some flags on each of your instances (except for the server/ server_containerized instance) in your `main.tf` file:

```hcl
host_settings = {
  proxy_containerized = {
    additional_packages = [ "venv-salt-minion" ]
    install_salt_bundle = true
  }
  suse_client = {
    additional_packages = [ "venv-salt-minion" ]
    install_salt_bundle = true
  }
  suse_minion = {
    additional_packages = [ "venv-salt-minion" ]
    install_salt_bundle = true
  }
```

## Advanced deployments

### Adding hosts to the testsuite

Several test hosts are optional and can be activated via a `host_settings` block like the following:

```hcl
host_settings = {
  proxy = {
  }
  suse_client = {
  }
  suse_minion = {
  }
  suse_sshminion = {
  }
  redlike_minion = {
  }
  deblike_minion = {
  }
  build_host = {
  }
  pxeboot_minion = {
  }
  kvm_host = {
  }
  monitoring_server = {
  }
}
```

The default value for `host_settings` block has a SUSE family traditional client and SUSE family minion present:

```hcl
host_settings = {
  suse_client = {
  }
  suse_minion = {
  }
}
```

Each of the hosts (including `server` and `controller` which are always present) accepts the following parameters:

- `provider_settings`: Map of provider-specific settings for the host, see the backend-specific README file
- `additional_repos` to add software repositories (see [README_ADVANCED.md](README_ADVANCED.md))
- `additional_packages` to add software packages (see [README_ADVANCED.md](README_ADVANCED.md))
- `additional_grains` to add or overwrite salt grains on salt minions. Map of key value
- `image` to use a different base image

A libvirt example follows:

```hcl
server = {
  provider_settings = {
    mac = "AA:B2:93:00:00:60"
  }
  additional_repos = {
    Test_repo = "http://dist.suse.de/ibs/Devel:/Galaxy:/Manager:/TEST/SLE_15_SP1/"
  }
  additional_packages = [ "vim" ]
}
```

The `cucumber_testsuite` module also offers the `use_avahi` and `avahi_reflector` variables, see [README_ADVANCED.md](README_ADVANCED.md) for their meaning.

## Mirror

You can configure a `mirror` host for the testsuite and that will be beneficial deploy performance, but presently an Internet connection will still be needed to deploy test hosts correctly.

## Alternative testsuite version

You can also select an alternative fork or branch for the Cucumber testsuite code:

- the `git_repo` variable in the `cucumber_testsuite` module overrides the fork URL (by default either the Uyuni or the SUSE Manager repository is used)
- the `branch` variable in the `cucumber_testsuite` module overrides the branch (by default an automatic selection is made).

As an example:

```hcl
module "cucumber_testsuite" {
  source = "./modules/cucumber_testsuite"

  product_version = "4.3-nightly"
  ...
  git_repo = "https://url.to.git/repo/to/clone"
  branch = "cool-feature"
  ...
}
```

## Alternative Docker and Kiwi profiles

By default, the Docker and Kiwi profiles used by the testsuite (all branches) are picked up from [the public Uyuni branch](https://github.com/uyuni-project/uyuni/tree/master/testsuite/features/profiles). If you want to experiment with alternative Docker or Kiwi profiles, you can do that with the `git_profiles_repo` variable.

Example:

```hcl
module "cucumber_testsuite" {
   ...
   git_profiles_repo = "https://url.to.git/repo/to/use"
   ...
}
```

## Alternative Container Registry server

If you want the test suite to use an unauthenticated container registry server, you can specify it with the `no_auth_registry` variable.

Example:

```hcl
module "cucumber_testsuite" {
   ...
   no_auth_registry = "uri.of.registry:443/used"
   ...
}
```

## Alternative Authenticated Docker Registry

If you want the test suite to use an authenticated Docker Registry, you can specify it with the `auth_registry`, `auth_registry_username`, and `auth_registry_password` variables.

Example:

```hcl
module "cucumber_testsuite" {
   ...
   auth_registry = "uri.of.auth.registry:5000/used"
   auth_registry_username = "username"
   auth_registry_password = "password"
   ...
}
```

## HTTP proxy for server

By default, the test suite has the SUSE Manager server do its HTTP requests directly on the internet. However, you may change this by using `server_http_proxy` variable, so the requests go through some squid proxy.

For example:

```hcl
module "cucumber_testsuite" {
   ...
   server_http_proxy = "name.of.proxy:3128"
   ...
}
```

## Custom download endpoint

By default, packages are downloaded from the SUSE Manager server via HTTP. However, we also test that they can be downloaded from a custom endpoint. You may set this up by using `custom_download_endpoint` variable.

For example:
```hcl
module "cucumber_testsuite" {
   ...
   custom_download_endpoint = "ftp://name.of.endpoint:445"
   ...
}
```

## Virtual host

You may need to change the KVM image download. To do it, use the `additional_grains` property:

```hcl
host_settings = {
  kvm_host = {
    additional_grains = {
      hvm_disk_image = {
        leap = {
          hostname = "hostname1"
          image = "..."
          hash = "..."
        }
      }
    }
  }
}
```
