# SSH backend

This backend, differently from others, assumes hosts already exist and can be accessed via SSH, thus configuring them for the desired roles (server, proxy, minion, etc.). You can use this backend to provision physical machines or in any situation where others are not applicable.

## First-time configuration

 - Copy `main.tf.ssh.example` to `main.tf`
 - Complete the missing information
 - Create a symbolic link to the `ssh` backend module directory inside the `modules` directory: `ln -sfn ../backend_modules/ssh modules/backend`

## Requirements

 - SSH access via password or private key to a user with root privileges
    - Access through a [bastion host](https://en.wikipedia.org/wiki/Bastion_host) is also possible using password or private key
 - Machine must come with `salt` pre-installed
 - If additional_network is needed one should make sure it is set up correctly and have the IP mask for it (this backend will not create it)

### Base module

Available provider settings for the base module:

| Variable name       | Type    | Default value | Description                                                                                                                                                                                   |
|---------------------|---------|---------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| private_key         | string  | null          | The contents of an SSH key to use. These can be loaded from a file on disk using the file function. This takes preference over the password if provided                                       |
| certificate         | string  | null          | The contents of a signed CA Certificate. The certificate argument must be used in conjunction with a private_key. These can be loaded from a file on disk using the the file function         |
| host_key            | string  | null          | The public key from the remote host or the signing CA, used to verify the connection                                                                                                          |
| bastion_host        | string  | null          | Bastion hostname                                                                                                                                                                              |
| bastion_host_key    | string  | null          | The public key for the bastion host                                                                                                                                                           |
| bastion_port        | string  | null          | The port for the bastion host                                                                                                                                                                 |
| bastion_user        | string  | null          | The user for the bastion host                                                                                                                                                                 |
| bastion_password    | string  | null          | The password for the bastion host                                                                                                                                                             |
| bastion_private_key | string  | null          | The contents of an SSH key file to use for the bastion host. These can be loaded from a file on disk using the file function                                                                  |
| bastion_certificate | string  | null          | The contents of a signed CA Certificate. The certificate argument must be used in conjunction with a bastion_private_key. These can be loaded from a file on disk using the the file function |
| timeout             | string  | "20s"         | The timeout to wait for the connection to become available. Should be a value like 30s or 5m                                                                                                  |
| additional_network  | string  | null          | A network mask for additional network                                                                                                                                                         |

### Host modules

Settings not set in host module will fall back to the value defined in base module it it exists there.

Following settings apply to all modules, such as `server`, `proxy`, `client`, `grafana`, `minion`, `mirror`, `sshminion` and `virthost`:

| Variable name       | Type    | Default value     | Description                                                                                                                                                                                   |
|---------------------|---------|-------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| host                | string  | null              | The address of the host to connect to                                                                                                                                                         |
| user                | string  | "root"            | The username for the connection                                                                                                                                                                   |
| password            | string  | "linux"           | The password for the connection                                                                                                                                                               |
| port                | number  | 22                | The port to connect to                                                                                                                                                                        |
| type                | string  | "ssh"             | The connection type that should be used. Valid types are ssh and winrm                                                                                                                        |
| private_key         | string  | base module value | The contents of an SSH key to use. These can be loaded from a file on disk using the file function. This takes preference over the password if provided                                       |
| certificate         | string  | base module value | The contents of a signed CA Certificate. The certificate argument must be used in conjunction with a private_key. These can be loaded from a file on disk using the the file function         |
| host_key            | string  | base module value | The public key from the remote host or the signing CA, used to verify the connection                                                                                                          |
| bastion_host        | string  | base module value | Bastion hostname                                                                                                                                                                              |
| bastion_host_key    | string  | base module value | The public key for the bastion host                                                                                                                                                           |
| bastion_port        | string  | base module value | The port for the bastion host                                                                                                                                                                 |
| bastion_user        | string  | base module value | The user for the bastion host                                                                                                                                                                 |
| bastion_password    | string  | base module value | The password for the bastion host                                                                                                                                                             |
| bastion_private_key | string  | base module value | The contents of an SSH key file to use for the bastion host. These can be loaded from a file on disk using the file function                                                                  |
| bastion_certificate | string  | base module value | The contents of a signed CA Certificate. The certificate argument must be used in conjunction with a bastion_private_key. These can be loaded from a file on disk using the the file function |
| timeout             | string  | base module value | The timeout to wait for the connection to become available. Should be a value like 30s or 5m                                                                                                  |

An example follows:
```hcl-terraform
 ...
 provider_settings = {
   host        = "192.168.1.1"
 }
 ...
```

## Dependency between modules

Clients an minions can only be set-up after the server provisioning. To ensure this behavior the output from server provision should be used as input on clients and minions.

Alternatively, one can provision the server beforehand and on a second step provision clients and minions.

An example with module dependency follows:

```hcl-terraform

module "server" {
  source = "./modules/server"
  ...
}

module "client" {
  source = "./modules/client"
  server_configuration = module.server.configuration
  ...
}
```
