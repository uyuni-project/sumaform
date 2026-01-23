{% if grains.get('testsuite') | default(false, true) %}

{% if not grains['osfullname'] in ['SLE Micro', 'SL-Micro'] %}
# Dependencies already satisfied by the images
# https://build.opensuse.org/project/show/systemsmanagement:sumaform:images:microos
minion_cucumber_requisites:
  pkg.installed:
    - pkgs:
{% if grains['install_salt_bundle'] %}
      - venv-salt-minion
{% else %}
      - salt-minion
{% endif %}
# Debian based systems don't come with curl installed, the test suite handles it with wget instead
{% if grains['os_family'] == 'Debian' %}
      - wget
{% endif %}
    - require:
      - sls: default
{% endif %}

{% if grains['os'] == 'SUSE' %}
{% if grains['osrelease'] in ['12', '15', '16'] %}

suse_minion_cucumber_requisites:
  pkg.installed:
    - pkgs:
      - aaa_base-extras
      - ca-certificates
    {% if 'build_image' not in grains.get('product_version', '') and 'paygo' not in grains.get('product_version', '') %}
    - require:
      - sls: repos
    {% endif %}

suse_certificate:
  file.managed:
    - name: /etc/pki/trust/anchors/SUSE_Trust_Root.crt.pem
    - source: salt://minion/certs/SUSE_Trust_Root.crt.pem
    - makedirs: True

update_ca_truststore:
  cmd.run:
    - name: /usr/sbin/update-ca-certificates
    - onchanges:
      - file: suse_certificate
    - require:
      - pkg: suse_minion_cucumber_requisites
    - unless:
      - fun: service.status
        args:
          - ca-certificates.path

{% endif %}
{% endif %}

# WORKAROUND for not syncing openSUSE Leap 15.6 or Leap 16.0 in the Uyuni CIs
# We need some dependencies for the package mgr-push, otherwise the installation in the test suite will fail
{% if grains['osfullname'] == 'Leap' and grains['osrelease'] in ['15.6', '16.0'] %}
suse_minion_mgr_push_requisites:
  pkg.installed:
    - pkgs:
      - hwdata
      - libgudev-1_0-0
{% if grains['osrelease'] in ['15.6'] %}
      - python3-dbus-python
      - python3-dmidecode
      - python3-extras
      - python3-hwdata
      - python3-libxml2
      - python3-pyudev
      - python3-rhnlib
{% endif %}
      - zchunk
{% endif %}

{% endif %}
