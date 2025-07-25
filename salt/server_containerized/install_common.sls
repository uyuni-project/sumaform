{%- set mirror_hostname = grains.get('server_mounted_mirror') if grains.get('server_mounted_mirror') else grains.get('mirror') %}

{% if grains['osfullname'] not in ['SLE Micro', 'SL-Micro', 'openSUSE Leap Micro'] %}
uyuni-tools:
  pkg.installed:
    - pkgs:
      - mgradm
      - mgrctl

{% if grains['osfullname'] == 'SLES' %}
ca_suse:
  pkg.installed:
    - pkgs:
      - ca-certificates-suse
{% endif %}

{%- else %}
check_mgrctl_installed:
  cmd.run:
    - name: "rpm -q mgrctl"
    - success_retcodes: [0]
    - failhard: True

check_mgradm_installed:
  cmd.run:
    - name: "rpm -q mgradm"
    - success_retcodes: [0]
    - failhard: True
{% endif %}

{% if mirror_hostname %}

nfs_client:
  pkg.installed:
    - name: nfs-client

non_empty_fstab:
  file.managed:
    - name: /etc/fstab
    - replace: false

mirror_directory:
  mount.mounted:
    - name: /srv/mirror
    - device: {{ mirror_hostname }}:/srv/mirror
    - fstype: nfs
    - mkmnt: True
    - require:
      - file: /etc/fstab
      - pkg: nfs_client

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []
