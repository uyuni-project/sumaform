mgradm_config:
  file.managed:
    - name: /root/mgradm.yaml
    - source: salt://server_containerized/mgradm.yaml
    - template: jinja

{% if not (grains.get('server_hub_peripheral') | default(false, true)) and not (grains.get('skip_server_install') | default(false, true)) %}
mgradm_install:
  cmd.run:
    - name: mgradm install podman --logLevel=debug --config /root/mgradm.yaml {{ grains['fqdn'] }}
    - unless: podman ps | grep uyuni-server
    - require:
      - sls: server_containerized.install_common
      - sls: server_containerized.install_podman
      - file: mgradm_config

{% set diskcheck_args = '--env DISKCHECKALERT=' ~ (grains.get('diskcheck_alert') | default(96, true))
  ~ ' --env DISKTHRESHOLD=' ~ (grains.get('diskthreshold') | default(98, true))
  ~ ' --env DISKCHECKALERT_FREE_MB=' ~ (grains.get('diskcheck_alert_free_mb') | default(307200, true))
  ~ ' --env DISKTHRESHOLD_FREE_MB=' ~ (grains.get('diskthreshold_free_mb') | default(51200, true)) %}
{% set custom_conf = '/etc/systemd/system/uyuni-server.service.d/custom.conf' %}

# Persist the disk check thresholds in the drop-in mgradm creates. Do not add another
# drop-in: a later one would replace the whole PODMAN_EXTRA_ARGS value. Options already
# present are kept and ours are appended. generated.conf is left to mgradm.
# The *_FREE_MB variables are ignored by images without uyuni PR #12707.
mgradm_diskcheck_thresholds:
  cmd.run:
    - shell: /bin/bash
    - name: |
        set -e
        f={{ custom_conf }}
        mkdir -p "$(dirname "$f")"
        if grep -q '^Environment="PODMAN_EXTRA_ARGS=' "$f" 2>/dev/null; then
          sed -i -E 's|^(Environment="PODMAN_EXTRA_ARGS=)([^"]*)"|\1\2 {{ diskcheck_args }}"|; s|PODMAN_EXTRA_ARGS= --env|PODMAN_EXTRA_ARGS=--env|' "$f"
        else
          printf '[Service]\nEnvironment="PODMAN_EXTRA_ARGS={{ diskcheck_args }}"\n' >> "$f"
        fi
    - unless: grep -q -e '--env DISKTHRESHOLD=' {{ custom_conf }}
    - require:
      - cmd: mgradm_install

mgradm_diskcheck_restart:
  cmd.run:
    - name: systemctl daemon-reload && mgradm restart
    - onchanges:
      - cmd: mgradm_diskcheck_thresholds
{% endif %}
