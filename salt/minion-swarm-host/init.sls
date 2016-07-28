include:
  - minion-swarm-host.repos

docker-main:
  pkg.installed:
    - pkgs:
        - docker
        - python-docker-py
    - require:
      - sls: minion-swarm-host.repos
    - unless: rpm -q docker && rpm -q python-docker-py

create-docker-partition:
  cmd.run:
    - name: /usr/sbin/parted -s /dev/vdb mklabel gpt && /usr/sbin/parted -s /dev/vdb mkpart primary 2048 100% && /sbin/mkfs.btrfs /dev/vdb1
    - unless: ls /dev/vdb1

docker-directory:
  file.directory:
    - name: /var/lib/docker
    - user: root
    - group: users
    - mode: 700
    - makedirs: True
  mount.mounted:
    - name: /var/lib/docker
    - device: /dev/vdb1
    - fstype: btrfs
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
        - cmd: create-docker-partition

docker-service:
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: docker-main
      - file: docker-directory

docker-sles-12-image:
  pkg.installed:
    - name: sles12-docker-image
    - require:
      - sls: minion-swarm-host.repos
    - unless: rpm -q sles-12-docker-image
  cmd.run:
    - name: cat /usr/share/suse-docker-images/sles12-docker.*.xz | docker import - suse/sles12
    - unless: docker history suse/sles12
    - require:
        - pkg: docker-sles-12-image
        - pkg: docker-main
        - service: docker-service

docker-minion-image:
  cmd.run:
    - name: docker build -t minion /srv/salt/minion-swarm-host/docker/minion
    - unless: docker history minion
    - require:
        - cmd: docker-sles-12-image
        - service: docker-service

run-script:
  file.managed:
    - name: /root/run.sh
    - source: salt://minion-swarm-host/run.sh
    - mode: 755
