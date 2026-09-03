{%- set version = grains['rhel_version'] | string -%}
{%- set image = 'ubi' ~ version ~ '-ssh' -%}
{%- set container = 'ubi' ~ version ~ '-client' -%}
{%- set ssh_port = grains.get('container_ssh_port', 2222) -%}
{%- set fqdn = grains['hostname'] ~ '.' ~ grains['domain'] -%}

include:
  - default

podman:
  pkg.installed:
    - require:
      - sls: default

build_directory:
  file.directory:
    - name: /root/ubi-build
    - makedirs: True

build_authorized_keys:
  file.managed:
    - name: /root/ubi-build/authorized_keys
    - contents: |
{%- for key in grains.get('authorized_keys', []) %}
        {{ key }}
{%- endfor %}
    - require:
      - file: build_directory

{% if version == '7' %}
build_centos7_repo:
  file.managed:
    - name: /root/ubi-build/centos7.repo
    - source: salt://rhel_container/centos7.repo
    - require:
      - file: build_directory
{% endif %}

build_containerfile:
  file.managed:
    - name: /root/ubi-build/Containerfile
    - source: salt://rhel_container/Containerfile
    - template: jinja
    - require:
      - file: build_directory

container_image:
  cmd.run:
    - name: podman build -t {{ image }} /root/ubi-build
    - require:
      - pkg: podman
    - onchanges:
      - file: build_containerfile
      - file: build_authorized_keys
{%- if version == '7' %}
      - file: build_centos7_repo
{%- endif %}

container_service:
  file.managed:
    - name: /etc/systemd/system/{{ container }}.service
    - contents: |
        [Unit]
        Description=Podman {{ container }}.service
        Wants=network-online.target
        After=network-online.target

        [Service]
        Environment=PODMAN_SYSTEMD_UNIT=%n
        Restart=on-failure
        ExecStartPre=/bin/rm -f %t/{{ container }}.pid
        ExecStartPre=-/usr/bin/podman rm -f {{ container }}
        ExecStart=/usr/bin/podman run --conmon-pidfile %t/{{ container }}.pid -d --name {{ container }} --hostname {{ fqdn }} --publish {{ ssh_port }}:22 --cap-add=AUDIT_WRITE {{ image }}
        ExecStop=-/usr/bin/podman stop -t 10 {{ container }}
        ExecStopPost=-/usr/bin/podman rm -f {{ container }}
        PIDFile=%t/{{ container }}.pid
        TimeoutStopSec=60
        Type=forking

        [Install]
        WantedBy=multi-user.target default.target
  service.running:
    - name: {{ container }}
    - enable: True
    - require:
      - cmd: container_image
    - watch:
      - file: container_service
      - cmd: container_image
