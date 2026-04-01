{% if 'client' in grains.get('roles') or 'minion' in grains.get('roles') or 'sshminion' in grains.get('roles') %}

# Recent distributions use drop-in configuration files
# in /etc/ssh/sshd_config.d/ instead of modifying the main file
{% set sshd_config = "/etc/ssh/sshd_config" %}
{% if grains['osfullname'] == 'openSUSE Tumbleweed' %}
  {% set sshd_config = "/etc/ssh/sshd_config.d/root.conf" %}
{% elif grains['osfullname'] == 'SLES' or grains['osfullname'] == 'Leap' %}
  {% if grains['osrelease'] == '16.0' %}
    {% set sshd_config = "/etc/ssh/sshd_config.d/root.conf" %}
  {% endif %}
{% elif grains['osfullname'] == 'SL-Micro' %}
  {% if grains['osrelease'] in ['6.0', '6.1', '6.2'] %}
    {% set sshd_config = "/etc/ssh/sshd_config.d/root.conf" %}
  {% endif %}
{% endif %}

ensure_sshd_config_exists:
  file.managed:
    - name: {{ sshd_config }}
    - replace: False
    - user: root
    - group: root
    - mode: '0600'
    - makedirs: True

sshd_change_challengeresponseauthentication:
  file.replace:
    - name: {{ sshd_config }}
    - pattern: "^ChallengeResponseAuthentication.*"
    - repl: "ChallengeResponseAuthentication yes"
    - append_if_not_found: True
{% endif %}
