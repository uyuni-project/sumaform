{% if 'client' in grains.get('roles') or 'minion' in grains.get('roles') or 'sshminion' in grains.get('roles') %}
# WORKAROUND: Leap 15.6 and SL-Micro 6.0 are using a different sshd_config. To be reviewed.
{% if grains['osfullname'] in ['openSUSE Tumbleweed'] %}
sshd_change_challengeresponseauthentication_tumbleweed:
  file.managed:
    - name: /etc/ssh/sshd_config.d/root.conf
    - contents: |
        ChallengeResponseAuthentication yes
{% elif not ( grains['osfullname'] in ['Leap', 'SL-Micro', 'openSUSE Tumbleweed'] and grains['osrelease'] in ['15.6', '6.0', '6.1'] ) %}
sshd_change_challengeresponseauthentication:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: "^ChallengeResponseAuthentication.*"
    - repl: "ChallengeResponseAuthentication yes"
{% endif %}
{% endif %}
