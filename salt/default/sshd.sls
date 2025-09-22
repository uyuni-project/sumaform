{% if 'client' in grains.get('roles') or 'minion' in grains.get('roles') or 'sshminion' in grains.get('roles') %}
# WORKAROUND: Leap 15.6 and SL-Micro 6.0 are using a different sshd_config. To be reviewed.
{% if not ( ('Leap' in grains['osfullname'] and grains['osrelease'] == '15.6')
        or ('SL-Micro' in grains['osfullname'] and grains['osrelease'] in ['6.0', '6.1'])
        or ('Tumbleweed' in grains['osfullname']) ) %}
sshd_change_challengeresponseauthentication:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: "^ChallengeResponseAuthentication.*"
    - repl: "ChallengeResponseAuthentication yes"
{% endif %}
{% endif %}
