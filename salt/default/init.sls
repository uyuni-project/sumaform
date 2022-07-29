include:
  - default.locale
  - default.minimal
  - default.pkgs
  - default.grub
  {% if grains.get('reset_ids') | default(false, true) %}
  - default.ids
  {% endif %}
  - default.testsuite

{% if grains.get('use_os_unreleased_updates') | default(False, true) or grains.get('use_os_released_updates') | default(False, true) %}
update_packages:
  pkg.uptodate:
    - require:
      - sls: repos
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

{% if grains.get('authorized_keys') %}
authorized_keys:
  file.append:
    - name: /root/.ssh/authorized_keys
    - text:
{% for key in grains['authorized_keys'] %}
      - {{ key }}
{% endfor %}
    - makedirs: True
{% endif %}
