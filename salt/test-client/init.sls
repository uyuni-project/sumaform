/root/.ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 700

ssh-setup:
  file.managed:
      - name: /root/.ssh/authorized_keys
      - source: salt://test-client/authorized_keys
