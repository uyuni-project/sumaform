# Cucumber testsuite

## Basic deployment

It is possible to run [the Cucumber testsuite for SUSE Manager and Uyuni](https://github.com/uyuni-project/uyuni/tree/master/testsuite) by using the `cucumber_testsuite` module. A libvirt example follows:

```hcl
provider "libvirt" {
  uri = "qemu:///system"
}

module "cucumber_testsuite" {
  source = "./modules/cucumber_testsuite"

  product_version = "4.0-nightly"

  cc_username = ...
  cc_password = ...

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

`product_version` determines the version under test, see [README_ADVANCED.md](README_ADVANCED.md) for the list of options.

## Getting outputs

By default, the `cucumber_testsuite` module will not produce any outputs for the resources (for example the hostname for the instances).

If you want them, add:

```hcl
output "configuration" {
  value = module.cucumber_testsuite.configuration
}
```
At the end of your `main.tf` file.

That will generate the outputs on-screen and will store them at the `terraform.tfstate`.

## Running the testsuite

To start the testsuite, use:

```
ssh -t head-ctl.tf.local run-testsuite
```

By default, `run-testsuite` runs over a selection of the YAML files at `run_sets`, i.e.:
`sanity_check.yml`, `core.yml`, `reposync.yml`, `init_clients.yml`, `secondary.yml`, `secondary_parallelizable.yml`, `finishing.yml`.

To enable/disable features, edit these YAML files. Keep in mind that:
 - features prefixed with `core_` are essential for others to work, cannot be repeated and must be executed in the order given by `testsuite.yml`
 - features not prefixed with `core_` are idempotent, so they can be run multiple times without changing test results.

Once all `core_` features have been executed you can run a non-core Cucumber feature as follows:
```
ssh -t head-ctl.tf.local cucumber spacewalk/testsuite/features/my_feature.feature
```

Read HTML results at:

 `head-ctl.tf.local/output.html`. There is an additional running service, enabled during the `highstate`, on the `controller` which is exposing the entire `/root/spacewalk/testsuite` folder: all testsuite files, including results saved under this folder, are readable through the `http` protocol at the port `80`.

Get HTML results with:
```
scp head-ctl.tf.local://root/spacewalk-testsuite-base/output.html .
```

To keep the testsuite running after ending the ssh session using `screen` tool:
```
ssh -t head-ctl.tf.local screen run-testsuite
```

You can detach from the session at anytime using the key sequence `^A d`. To re-attach to the existing session:
```
ssh -t head-ctl.tf.local screen -r
```

## Advanced deployments

### Adding hosts to the testsuite

Several test hosts are optional and can be activated via a host_settings block like the following:

```hcl
host_settings = {
  pxy = {
    present = true
  }
  cli-sles12sp4 = {
    present = true
  }
  min-sles12sp4 = {
    present = true
  }
  min-build = {
    present = true
  }
  minssh-sles12sp4 = {
    present = true
  }
  min-centos7 = {
    present = true
  }
  min-ubuntu1804 = {
    present = true
  }
  min-pxeboot = {
    present = true
  }
  min-kvm = {
    present = true
  }
}
```

The default value for host_settings block has a SLES12SP4 Traditional Client and SLES12SP4 Minion present:

```hcl
host_settings = {
  cli-sles12sp4 = {
    present = true
  }
  min-sles12sp4 = {
    present = true
  }
}
```

In addition to the `present` flag, each of the hosts (including `srv` and `ctl` which are always present) accepts the following parameters:
 - `provider_settings`: Map of provider-specific settings for the host, see the backend-specific README file
 - `additional_repos` to add software repositories (see [README_ADVANCED.md](README_ADVANCED.md))
 - `image` to use a different base image

A libvirt example follows:

```hcl
srv = {
  provider_settings = {
    mac = "AA:B2:93:00:00:60"
  }
  additional_repos = {
    Test_repo = "http://download.suse.de/ibs/Devel:/Galaxy:/Manager:/TEST/SLE_15_SP1/"
  }
}
````

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

  product_version = "4.0-nightly"
  ...
  git_repo = "https://url.to.git/repo/to/clone"
  branch = "cool-feature"
  ...
}
```

## Alternative Docker and Kiwi profiles

By default, the Docker and Kiwi profiles used by the testsuite (all branches) are picked up from [the public uyuni branch](https://github.com/uyuni-project/uyuni/tree/master/testsuite/features/profiles). If you want to experiment with alternative Docker or Kiwi profiles, you can do that with the `git_profiles_repo` variable.

Example:

```hcl
module "cucumber_testsuite" {
   ...
   git_profiles_repo = "https://url.to.git/repo/to/use"
   ...
}
```

## Alternative Portus server

If you want the test suite to use a Portus server, you can specify it with the `portus_uri`, `portus_username`, and `portus_password` variables.

Example:

```hcl
module "cucumber_testsuite" {
   ...
   portus_uri = "uri.of.portus:5000/used"
   portus_username = "username"
   portus_password = "password"
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
