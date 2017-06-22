hosts_file:
  file.append:
    - name: /etc/hosts
    - text: "127.0.1.1 {{ grains['hostname'] }}.{{ grains['domain'] }} {{ grains['hostname'] }}"

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
