mgradm_config:
  file.managed:
    - name: /root/mgradm.yaml
    - source: salt://server_containerized/mgradm.yaml
    - template: jinja

{% if not (grains.get('server_hub_peripheral') | default(false, true)) %}
mgradm_install:
  cmd.run:
    - name: mgradm install podman --logLevel=debug --config /root/mgradm.yaml {{ grains['fqdn'] }}{% if grains.get('server_hub_main') | default(false, true) %} --hubxmlrpc-replicas 1{% endif %}
    - unless: podman ps | grep uyuni-server
    - require:
      - sls: server_containerized.install_common
      - sls: server_containerized.install_podman
      - file: mgradm_config
{% endif %}
