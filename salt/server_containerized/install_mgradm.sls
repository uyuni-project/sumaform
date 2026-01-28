mgradm_config:
  file.managed:
    - name: /root/mgradm.yaml
    - source: salt://server_containerized/mgradm.yaml
    - template: jinja

mgradm_install:
  cmd.run:
    - name: mgradm install podman --logLevel=debug --config /root/mgradm.yaml {{ grains['fqdn'] }}
    - unless: podman ps | grep uyuni-server
    - require:
      - sls: server_containerized.install_common
      - sls: server_containerized.install_podman
      - file: mgradm_config
