systemd_machine_id:
  cmd.run:
    - name: rm -f /etc/machine-id && rm -f /var/lib/dbus/machine-id && dbus-uuidgen --ensure && systemd-machine-id-setup && touch /etc/machine-id-already-setup
    - creates: /etc/machine-id-already-setup
    - onlyif: test -f /usr/bin/systemd-machine-id-setup

dbus_machine_id:
  cmd.run:
    - name: rm -f /var/lib/dbus/machine-id && dbus-uuidgen --ensure
    - creates: /var/lib/dbus/machine-id
    - unless: test -f /usr/bin/systemd-machine-id-setup

minion_id_cleared:
  file.absent:
    - name: /etc/salt/minion_id
