## Project areas

## Important note

While sumaform is still compatible with terraform as of 2025/11/24, we expect all contributions to be tested and compatible with OpenTofu.

Therefore, this documentation describes OpenTofu and not Terraform anymore.

As a contributor, you are encouraged to not break things for terraform on purpose. But if you need a feature available only on OpenTofu, make sure you evaluate if it will affect all deployments, and if so make sure this is documented properly.

### Base OS images

openSUSE images are built and tracked in the [Open Build Service](https://build.opensuse.org/):

- [libvirt project](https://build.opensuse.org/project/show/systemsmanagement:sumaform:images:libvirt)

[Submit Requests](https://openbuildservice.org/help/manuals/obs-reference-guide/cha.obs.request_and_review_ystem.html) can be created with a free account, project maintainership is given to meritable community members.

SUSE Linux Enterprise images are built and tracked in [SUSE's internal OBS instance](https://build.suse.de/project/show/Devel:Galaxy:Terraform:Images):

- [libvirt project](https://build.suse.de/project/show/Devel:Galaxy:Terraform:Images)
- [AWS project](https://build.suse.de/project/show/Devel:Galaxy:Terraform:Images:AmazonEC2)

Access is limited to SUSE employees at this time.

Please note that all of the above projects have the build flag disabled unless some change is ongoing to prevent spontaneous rebuilds. Please click on *Repositories* -> *Build Flag* -> hover the gear icon in the top-left corner of the table (*All*, *All*) -> *Enable* until all images are rebuilt.

Non-SUSE images are built and tracked in the [sumaform-images](https://github.com/uyuni-project/sumaform-images) GitHub project. [Pull Requests](https://help.github.com/articles/about-pull-requests/) can be created with a free account, write access is given to meritable community members.

### Software Packages

sumaform requires a specific OpenTofu version and provides several special-purpose RPM packages as well. Those are built and tracked inthe [Open Build Service](https://build.opensuse.org/):

- the [systemsmanagement:sumaform](https://build.opensuse.org/project/show/systemsmanagement:sumaform) project builds `opentofu` and `terraform-provider-libvirt` with some dependencies
- the [systemsmanagement:sumaform:tools](https://build.opensuse.org/project/show/systemsmanagement:sumaform:tools) project builds other software meant to be installed in sumaformed machines

[Submit Requests](https://openbuildservice.org/help/manuals/obs-reference-guide/cha.obs.request_and_review_ystem.html) can be created with a free account, project maintainership is given to meritable community members.

#### OpenTofu and terraform-provider libvirt upgrade instructions

OpenTofu:

```bash
osc checkout systemsmanagement:sumaform
osc up systemsmanagement:sumaform
cd systemsmanagement:sumaform/opentofu
vim _service # change versions
osc service disabledrun
osc build openSUSE_Leap_16.0 # check building is fine
osc add <new files>
osc rm <old files>
osc vc # describe changes
osc commit
```

terraform-provider-libvirt:

```bash
osc checkout systemsmanagement:sumaform
osc up systemsmanagement:sumaform
cd systemsmanagement:sumaform/terraform-provider-libvirt
vim _service # change versions
osc service disabledrun
osc build openSUSE_Leap_15.0 # check building is fine
osc add <new files>
osc rm <old files>
osc vc # describe changes
osc commit
```

### Salt states and OpenTofu modules

Those are tracked in this project. [Pull Requests](https://help.github.com/articles/about-pull-requests/) can be created with a free account, write access is given to meritable community members.
