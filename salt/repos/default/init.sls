{% for keypath in grains.get('gpg_keys') | default([], true) %}
  {% set keyname =  salt['file.basename'](keypath)  %}

gpg_key_copy_{{ keypath }}:
  file.managed:
    - name: /tmp/{{ keyname }}
    - source: salt://{{ keypath }}

install_{{ keypath }}:
  cmd.wait:
    - name: rpm --import /tmp/{{ salt['file.basename'](keypath) }}
    - watch:
      - file: /tmp/{{ keyname }}

{% endfor %}

include:
  {%- if grains['os_family'] == 'Suse' %}
  - .suse
  {%- elif grains['os_family'] == 'RedHat' %}
  - .redhat
  {%- elif grains['os_family'] == 'Debian' %}
  - .debian
  {%- endif %}

{# WORKAROUND: see github:saltstack/salt#10852 #}
{{ sls }}_nop:
  test.nop: []
