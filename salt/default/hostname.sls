temporary_hostname:
  cmd.run:
    {% if grains['init'] == 'systemd' %}
    - name: hostnamectl set-hostname {{ grains['hostname'] }}.{{ grains['domain'] }}
    {% else %}
    - name: hostname {{ grains['hostname'] }}.{{ grains['domain'] }}
    {% endif %}

permanent_hostname:
  file.managed:
    - name: /etc/hostname
    - contents: {{ grains['hostname'] }}

permanent_hostname_backward_compatibility_link:
  file.symlink:
    - name: /etc/HOSTNAME
    - force: true
    - target: /etc/hostname

{% if grains['os_family'] != 'RedHat' %}

lost_fqdn_at_reboot_workaround_bsc820213:
  file.managed:
    - name: /usr/lib/systemd/system/hostname-init.service
    - user: root
    - group: root
    - mode: 644
    - contents:
      - "[Unit]"
      - "Description=Hostname initialization service"
      - ""
      - "[Service]"
      - "Type=simple"
      - "ExecStart=/usr/bin/hostnamectl set-hostname {{ grains['hostname'] }}.{{ grains['domain'] }}"
      - ""
      - "[Install]"
      - "WantedBy=multi-user.target"

workaround_enabled:
  service.enabled:
    - name: hostname-init
    - requires: lost_fqdn_at_reboot_workaround_bsc820213

{% endif %}
