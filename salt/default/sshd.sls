{% if 'client' in grains.get('roles') or 'minion' in grains.get('roles') or 'sshminion' in grains.get('roles') %}

{% if grains['osfullname'] == 'openSUSE Tumbleweed' %}
  {% set sshd_config = "etc/ssh/sshd_config.d/root.conf" %}
{% elif grains['osfullname'] == 'SLES' or grains['osfullname'] == 'Leap' %}
  {% if grains['osrelease'] == '16.0' %}
    {% set sshd_config = "etc/ssh/sshd_config.d/root.conf" %}
  {% else %}
    {% set sshd_config = "/etc/ssh/sshd_config" %}
  {% endif %}
{% elif grains['osfullname'] == 'SL-Micro' %}
  {% if grains['osrelease'] == '6.2' %}
    {% set sshd_config = "etc/ssh/sshd_config.d/root.conf" %}
  {% else %}
    {% set sshd_config = "/etc/ssh/sshd_config" %}
  {% endif %}
{% else %}
  {% set sshd_config = "/etc/ssh/sshd_config" %}
{% endif %}

sshd_change_challengeresponseauthentication:
  file.replace:
    - name: {{sshd_config}}
    - pattern: "^ChallengeResponseAuthentication.*"
    - repl: "ChallengeResponseAuthentication yes"
    - append_if_not_found: True

{% endif %}
