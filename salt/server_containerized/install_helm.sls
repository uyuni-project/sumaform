
### Once the helm chart is done, we have to prepare some kind of json with the parameters of the installation like the one we have for install_mgradm. 

helm_install:
  cmd.run:
    - name: cat /etc/os-release # Dummy command to leave something there until the helm chart is prepared.
    - require:
      - sls: server_containerized.install_rke2
    - env:
      - KUBECONFIG: /etc/rancher/rke2/rke2.yaml
    - unless: helm --kubeconfig /etc/rancher/rke2/rke2.yaml list | grep uyuni
