{% if 'client' in grains.get('roles') or 'minion' in grains.get('roles') or 'sshminion' in grains.get('roles') %}

sshd_change_challengeresponseauthentication:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: "^ChallengeResponseAuthentication.*"
    - repl: "ChallengeResponseAuthentication yes"

{% endif %}
