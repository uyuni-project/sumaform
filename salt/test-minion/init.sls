/root/.ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 700

ssh-setup-minion:
  file.managed:
      - name: /root/.ssh/authorized_keys
      - source: salt://test-minion/authorized_keys

salt-minion:
  pkg.installed

config-minion:
  file.replace:
    - name: /etc/salt/minion
    - pattern: ^#master : salt
    - repl: master = control-node.tf.local
    - require :
      - salt-minion 

salt-minion:
  service.running:
    - enable : True

