include:
  - default.locale
  - default.update
  - default.minimal
  - default.pkgs
  - default.sshd
  {% if grains.get('reset_ids') | default(false, true) %}
  - default.ids
  {% endif %}
  {% if not grains['osfullname'] in ['SLE Micro', 'SL-Micro'] %}
  # Dependencies already satisfied by the images
  # https://build.opensuse.org/project/show/systemsmanagement:sumaform:images:microos
  - default.testsuite
  {% endif %}


{% if grains.get('swap_file_size', "0")|int() > 0 %}
file_swap:
  cmd.run:
    - name: |
        {% if grains['os_family'] == 'RedHat' %}dd if=/dev/zero of=/extra_swapfile bs=1048576 count={{grains['swap_file_size']}}{% else %}fallocate --length {{grains['swap_file_size']}}MiB /extra_swapfile{% endif %}
        chmod 0600 /extra_swapfile
        mkswap /extra_swapfile
    - creates: /extra_swapfile
  mount.swap:
    - name: /extra_swapfile
    - persist: true
    - require:
      - cmd: file_swap
{% endif %}

{% if grains['authorized_keys'] %}
authorized_keys:
  file.append:
    - name: /root/.ssh/authorized_keys
    - text:
{% for key in grains['authorized_keys'] %}
      - {{ key }}
{% endfor %}
    - makedirs: True
{% endif %}

{% if grains.get('salt_log_level') %}

write_debug:
  file.replace:
    - name: /etc/venv-salt-minion/minion.d/00-venv.conf
    - pattern: '^log_level\s*.*'
    - repl: 'log_level: {{ grains.get('salt_log_level', 'warning') }}'
    - append_if_not_found: true
{% endif %}
