include:
  - sles

lftp-repo:
  file.managed:
    - name: /etc/zypp/repos.d/terraform-sles12sp1-x86_64.repo
    - source: salt://package-mirror/repos.d/terraform-sles12sp1-x86_64.repo

refresh-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - sls: sles
      - file: lftp-repo

lftp:
  pkg.installed:
    - version: '>=4.6.4-1.1'
    - require:
      - cmd: refresh-repos

/root/mirror.lftp:
  file.managed:
    - source: salt://package-mirror/mirror.lftp

/root/mirror.sh:
  file.managed:
    - source: salt://package-mirror/mirror.sh
    - mode: 755
  cron.present:
    - identifier: PACKAGE_MIRROR
    - user: root
    - hour: 20
    - minute: 0
    - require:
      - file: /root/mirror.sh
      - file: /root/mirror.lftp
      - pkg: lftp

vdb1.device:
    cmd.run:
      - name: /usr/sbin/parted -s /dev/vdb mklabel gpt && /usr/sbin/parted -s /dev/vdb mkpart primary 2048 100% && /sbin/mkfs.ext4 /dev/vdb1
      - unless: ls /dev/vdb1

# http serving of mirrored packages
/etc/fstab:
  file.managed

/srv/mirror:
  file.directory:
    - user: wwwrun
    - group: users
    - mode: 755
    - makedirs: True
  mount.mounted:
    - device: /dev/vdb1
    - fstype: ext4
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: vdb1.device

web_server:
  pkg.installed:
    - name: apache2
    - require:
      - cmd: refresh-repos
  file.managed:
    - name: /etc/apache2/vhosts.d/package-mirror.conf
    - source: salt://package-mirror/package-mirror.conf
    - require:
      - pkg: apache2
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: apache2
      - file: /etc/apache2/vhosts.d/package-mirror.conf
      - file: /srv/mirror
    - watch:
      - file: /etc/apache2/vhosts.d/package-mirror.conf

# NFS serving of mirrored packages

/etc/exports:
  file.append:
    - text: /srv/mirror *(ro,sync,no_root_squash)
    - require:
      - file: /srv/mirror

rpcbind:
  service.running:
    - enable: True

nfs:
  service.running:
    - enable: True
    - require:
      - service: rpcbind
nfsserver:
  service.running:
    - enable: True
    - require:
      - file: /etc/exports
      - service: nfs
    - watch:
      - file: /etc/exports

# SUSE Manager "from dir" specific files

/srv/mirror/organizations_products_unscoped.json:
  file.managed:
    - source: salt://package-mirror/organizations_products_unscoped.json
    - require:
      - file: /srv/mirror

/srv/mirror/organizations_repositories.json:
  file.managed:
    - source: salt://package-mirror/organizations_repositories.json
    - require:
      - file: /srv/mirror

/srv/mirror/organizations_subscriptions.json:
  file.managed:
    - source: salt://package-mirror/organizations_subscriptions.json
    - require:
      - file: /srv/mirror

/srv/mirror/organizations_orders.json:
  file.managed:
    - source: salt://package-mirror/organizations_orders.json
    - require:
      - file: /srv/mirror

/srv/mirror/SUSE:
  file.symlink:
    - target: mirror/SuSE/build.suse.de/SUSE
