{% if grains['additional_repos'] %}
{% for label, url in grains['additional_repos'].items() %}
{{ label }}_repo:
  pkgrepo.managed:
    - humanname: {{ label }}
  {%- if grains['os_family'] == 'Debian' %}
  {%- if 'uyuni-pr' in grains.get('product_version', '') %}
    - name: deb [trusted=yes] {{ url }} /
    - file: /etc/apt/sources.list.d/sumaform_additional_repos.list
  {%- else %}
    - name: deb {{ url }} /
    - file: /etc/apt/sources.list.d/sumaform_additional_repos.list
    - key_url: {{ url }}/Release.key
  {%- endif %}
  {%- else %}
    - baseurl: {{ url }}
    - priority: 95
    - gpgcheck: 0
  {%- endif %}

# WORKAROUND: to have additional_repos have priority over normal tools we hardcode the hostname originating them (in the future we may want to add an
# input variable to match against origin or release file fields
# Ref: https://wiki.debian.org/AptPreferences
{% if grains['os_family'] == 'Debian' and grains['os'] == 'Ubuntu' %}
{{ label }}_customrepo_raised_priority:
  file.append:
    - name: /etc/apt/preferences.d/sumaform_additional_repos
    - text: |
        Package: *
        Pin: origin download.opensuse.org
        Pin-Priority: 900
        Package: *
        Pin: origin download.suse.de
        Pin-Priority: 850
    - unless: ls /etc/apt/preferences.d/sumaform_additional_repos
{% endif %}
{% endfor %}
{% endif %}

{% if grains['additional_certs'] %}
{% for label, url in grains['additional_certs'].items() %}
{{ label }}_cert:
  file.managed:
    - name: /etc/pki/trust/anchors/{{ label }}
    - source: {{ url }}
    - source_hash: {{ url }}.sha512

{% if grains['os'] == 'SUSE' %}
update-ca-certificates:
  cmd.run:
    - name: /usr/sbin/update-ca-certificates
{%- if grains['saltversioninfo'][0] >= 3002 %} # Workaround for bsc#1188641
    - unless:
      - fun: service.status
        args:
          - ca-certificates.path
{%- endif %}
{% endif %}
{% endfor %}
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []
