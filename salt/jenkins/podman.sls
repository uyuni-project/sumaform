podman:
  pkg.installed:
    - name: podman
    - require:
      - sls: default
  user.present:
    - name: podman
    - fullname: podman
    - usergroup: true
    - shell: /bin/nologin
    - home: /var/lib/podman
    - system: true
  cmd.run:
    - name: usermod --add-subuids 200000-201000 --add-subgids 200000-201000 podman
    - user: root
    - require:
      - user: podman
