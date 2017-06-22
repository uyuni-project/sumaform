systemd_machine_id:
  cmd.run:
    - name: rm /etc/machine-id && systemd-machine-id-setup && touch /etc/machine-id-already-setup
    - creates: /etc/machine-id-already-setup
    - onlyif: test -f /usr/bin/systemd-machine-id-setup

dbus_machine_id:
  cmd.run:
    - name: dbus-uuidgen --ensure
    - creates: /var/lib/dbus/machine-id
    - unless: test -f /usr/bin/systemd-machine-id-setup

minion_id_cleared:
  file.absent:
    - name: /etc/salt/minion_id
