{% if 'client' in grains.get('roles') or 'minion' in grains.get('roles') or 'sshminion' in grains.get('roles') %}
# WORKAROUND: Leap 15.6 and SL-Micro 6.0 are using a different sshd_config. To be reviewed.
{% if not ( grains['osfullname'] in ['Leap', 'SL-Micro', 'Tumbleweed'] and grains['osrelease'] in ['15.6', '6.0', '6.1'] ) %}
sshd_change_challengeresponseauthentication:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: "^ChallengeResponseAuthentication.*"
    - repl: "ChallengeResponseAuthentication yes"
{% endif %}
{% endif %}
