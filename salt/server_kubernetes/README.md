# server_kubernetes

Salt state used to prepare a host to run the Uyuni/Multi-Linux Manager server
on an [RKE2](https://docs.rke2.io/) Kubernetes cluster (`kubernetes = true` in
the `cucumber_testsuite` module, see `main.tf.libvirt.rke.example`).

This state does **not** install RKE2, nor does it install the server itself.
It only prepares the host for that installation: it installs the RKE2/Helm
dependencies, generates the self-signed certificate and Helm `values.yaml`
files, exchanges SSH keys with the proxy host, and exports the environment
variables consumed by the installation (`HELM_CHART_NAME`, `HELM_CHART_URL`,
`VALUES_YAML_PATH`, ...) to `/etc/profile.d/server_kubernetes_vars.sh`.

## Installing RKE2 and the server/proxy

Once sumaform has finished provisioning, install RKE2 and deploy the server
and proxy Helm charts from the `controller` host by running the following
`rake` tasks from the testsuite checkout, **in this exact order**:

```bash
cd /root/spacewalk/testsuite
rake cucumber:kubernetes_install_rke2
rake cucumber:kubernetes_install_mlm_server_on_rke2
rake cucumber:kubernetes_install_mlm_proxy_on_rke2
```

- `kubernetes_install_rke2` installs and starts RKE2.
- `kubernetes_install_mlm_server_on_rke2` deploys the server Helm chart onto
  the RKE2 cluster.
- `kubernetes_install_mlm_proxy_on_rke2` deploys the proxy Helm chart; it
  depends on the server already being up, so it must run last.

This is also how our CI pipelines run them (the snippet below keeps only the
rake invocations; the actual jobs wrap each one with extra logging, timeout
and parameter handling that is not relevant here):

```groovy
stage('Install RKE2') {
    sh 'rake cucumber:kubernetes_install_rke2'
}
stage('Install Server on RKE2') {
    sh 'rake cucumber:kubernetes_install_mlm_server_on_rke2'
}
stage('Install Proxy on RKE2') {
    sh 'rake cucumber:kubernetes_install_mlm_proxy_on_rke2'
}
```

