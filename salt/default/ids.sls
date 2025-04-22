{% if grains['os_family'] == 'RedHat' %}
{% if grains['osfinger'] == 'Red Hat Enterprise Linux-9' or grains['osfinger'] == 'Amazon Linux-2023' %}
install_dbus_uuidgen:
  pkg.installed:
    - pkgs:
      - dbus-tools
{% endif %}
{% endif %}

systemd_machine_id:
  cmd.run:
    - name: >
        bash -c '
        set -e
        echo "Removing existing machine-id files"
        rm -f /etc/machine-id
        rm -f /var/lib/dbus/machine-id

        echo "Creating /var/lib/dbus"
        mkdir -p /var/lib/dbus

        echo "Generating new D-Bus UUID"
        dbus-uuidgen --ensure

        echo "Running systemd-machine-id-setup"
        systemd-machine-id-setup

        echo "Checking if /var/log/journal exists and is not empty"
        if [ -d /var/log/journal ] && [ "$(ls -A /var/log/journal)" ]; then
          MID=$(cat /etc/machine-id)
          echo "Moving logs to /var/log/journal/$MID"
          mkdir -p /var/log/journal/$MID
          mv /var/log/journal/* /var/log/journal/$MID/
        else
          echo "/var/log/journal does not exist or is empty, skipping move"
        fi

        echo "Marking setup complete"
        touch /etc/machine-id-already-setup
        '
    - creates: /etc/machine-id-already-setup
    - onlyif: test -f /usr/bin/systemd-machine-id-setup -o -f /bin/systemd-machine-id-setup



dbus_machine_id:
  cmd.run:
    - name: rm -f /var/lib/dbus/machine-id && dbus-uuidgen --ensure
    - creates: /var/lib/dbus/machine-id
    - unless: test -f /usr/bin/systemd-machine-id-setup -o -f /bin/systemd-machine-id-setup

minion_id_cleared:
  file.absent:
{% if grains['install_salt_bundle'] %}
    - name: /etc/venv-salt-minion/minion_id
{% else %}
    - name: /etc/salt/minion_id
{% endif %}
