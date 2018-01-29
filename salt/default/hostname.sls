# set the hostname in the kernel, this is needed for Red Hat systems
# and does not hurt in others
kernel_hostname:
  cmd.run:
    - name: sysctl kernel.hostname={{ grains['hostname'] }}
    - unless: sysctl --values kernel.hostname | grep -w {{ grains['hostname'] }}

# set the hostname in userland. There is no consensus among distros
# but Debian prefers the short name, SUSE demands the short name,
# Red Hat suggests the FQDN but works with the short name.
# Bottom line: short name is used here
temporary_hostname:
  cmd.run:
    {% if grains['init'] == 'systemd' %}
    - name: hostnamectl set-hostname {{ grains['hostname'] }}
    {% else %}
    - name: hostname {{ grains['hostname'] }}
    {% endif %}

# set the hostname in the filesystem, matching the temporary hostname
permanent_hostname:
  file.managed:
    - name: /etc/hostname
    - contents: {{ grains['hostname'] }}

# /etc/HOSTNAME is supposed to always contain the FQDN
legacy_permanent_hostname:
  file.managed:
    - name: /etc/HOSTNAME
    - follow_symlinks: False
    - contents: {{ grains['hostname'] }}.{{ grains['domain'] }}

# set the hostname and FQDN name in /etc/hosts
# this is not needed if a proper DNS server is in place, but when using avahi this
# might not be the case. The script tries to to use real IP addresses in order not
# to break round-robin DNS resolution and only uses 127.0.1.1 as a last resort.
{% if grains['use_avahi'] %}
hosts_file_hack:
  cmd.script:
    - name: salt://default/set_ip_in_etc_hosts.py.jinja
    - args: "{{ grains['hostname'] }} {{ grains['domain'] }}"
    - template: jinja
    - context:
    {% if grains.get('osmajorrelease', None)|int() == 15 %}
      pythonexec: python3
    {% else %}
      pythonexec: python
    {% endif %}
{% endif %}
