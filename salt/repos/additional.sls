# Skip Micro OSes, given the additional repos are set up by combustion/ignition/cloud-init.
{% if (grains['osfullname'] not in ['SLE Micro', 'SL-Micro', 'openSUSE Leap Micro']) %}
{% if grains['additional_repos'] %}
{% for label, url in grains['additional_repos'].items() %}
{{ label }}_repo:
  pkgrepo.managed:
    - humanname: {{ label }}_repo
  {%- if grains['os_family'] == 'Debian' %}
    - name: deb {{ url }} /
    - file: /etc/apt/sources.list.d/sumaform_additional_repos.list
    - key_url: {{ url }}/Release.key
  {%- else %}
    {#- Pool media repos keep the default priority, or their older packages hide newer updates #}
    - baseurl: {{ url }}
    - refresh: True
    - priority: {{ 99 if '-POOL-' in url else 95 }}
    - gpgcheck: 0
  {%- endif %}

{% if grains['os_family'] == 'Suse' and '-POOL-' not in url %}
{{ label }}_repo_shadow_check:
  cmd.script:
    - name: salt://repos/check_shadowed_packages.sh
    - args: {{ label }}_repo
    - require:
      - pkgrepo: {{ label }}_repo
{% endif %}

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
        Pin: origin dist.suse.de
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
    - unless:
      - fun: service.status
        args:
          - ca-certificates.path
{% endif %}
{% endfor %}
{% endif %}
{% endif %}
# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []
