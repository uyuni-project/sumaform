include:
  - default

/etc/sudoers:
  file.replace:
    - pattern: '^#includedir /etc/sudoers'
    - repl: '##includedir /etc/sudoers'

