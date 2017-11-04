hosts_file_ipv4:
  host.present:
    - ip: 127.0.1.1
    - names:
      - {{ grains['hostname'] }}.{{ grains['domain'] }}
      - {{ grains['hostname'] }}

hosts_file_ipv6:
  host.present:
    - ip: ::1
    - names:
      - {{ grains['hostname'] }}.{{ grains['domain'] }}

temporary_hostname:
  cmd.run:
    {% if grains['init'] == 'systemd' %}
    - name: hostnamectl set-hostname {{ grains['hostname'] }}
    {% else %}
    - name: hostname {{ grains['hostname'] }}
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
