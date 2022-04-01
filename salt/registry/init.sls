include:
  - default
  - repos

podman:
  pkg.installed:
    - require:
      - sls: default

registry_directory:
  file.directory:
    - name: /var/lib/registry

# generated via
# podman create --name registry --publish 5000:80 -v /var/lib/registry:/var/lib/registry docker.io/library/registry:2
# podman generate systemd --name --new registry
# replace KillMode=none with TimeoutStopSec=60 as per https://github.com/containers/podman/pull/8889

registry_service:
  file.managed:
    - name: /etc/systemd/system/registry.service
    - contents: |
        [Unit]
        Description=Podman container-registry.service
        Documentation=man:podman-generate-systemd(1)
        Wants=network.target
        After=network-online.target

        [Service]
        Environment=PODMAN_SYSTEMD_UNIT=%n
        Restart=on-failure
        ExecStartPre=/bin/rm -f %t/container-registry.pid %t/container-registry.ctr-id
        ExecStart=/usr/bin/podman run --conmon-pidfile %t/container-registry.pid --cidfile %t/container-registry.ctr-id --cgroups=no-conmon -d --replace --name registry --publish 80:5000 -v /var/lib/registry:/var/lib/registry docker.io/library/registry:2
        ExecStop=/usr/bin/podman stop --ignore --cidfile %t/container-registry.ctr-id -t 10
        ExecStopPost=/usr/bin/podman rm --ignore -f --cidfile %t/container-registry.ctr-id
        PIDFile=%t/container-registry.pid
        TimeoutStopSec=60
        Type=forking

        [Install]
        WantedBy=multi-user.target default.target
  service.running:
    - name: registry
    - enable: True
