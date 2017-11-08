hostname:
  cmd.script:
    - name: salt://default/set_hostname.py
    - args: "{{ grains['hostname'] }} {{ grains['domain'] }}"
