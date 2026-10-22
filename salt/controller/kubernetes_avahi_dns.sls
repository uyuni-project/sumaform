# Runs last so that the controller SSH key from controller/init.sls is in place
kubernetes_avahi_dns:
  cmd.script:
    - name: salt://controller/kubernetes_avahi_dns.sh
    - template: jinja
    - order: last
