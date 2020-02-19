# null backend

- Create a symbolic link to the `libvirt` backend module directory inside the `modules` directory: `ln -sfn ../backend_modules/null modules/backend`

This backend goal is test configuration. Any change in the `main.tf` file in use will trigger changes in machines.

Existing modules:

- `base`
- `bost`

# Interface for other backend's

All `variable.tf` and `version.tf` present in these backend modules are shared with all other backend modules.
The goal is to have a kind of interface that can be used but modules in `modules` directory and ensure compatibility between all backends.
