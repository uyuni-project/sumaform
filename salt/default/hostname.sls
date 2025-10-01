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

{% if grains['os_family'] == 'Suse' and grains["osfullname"] not in ['SL-Micro', 'openSUSE Tumbleweed'] and grains["osmajorrelease"] < 16 %}
change_searchlist:
  file.replace:
    - name: /etc/sysconfig/network/config
    - pattern: NETCONFIG_DNS_STATIC_SEARCHLIST=.*
    - repl: NETCONFIG_DNS_STATIC_SEARCHLIST="{{ grains['domain'] }}"

netconfig_update:
  cmd.run:
    - name: netconfig update
    - require:
      - file: change_searchlist
{% else %}
change_searchlist:
  file.append:
    - name: /etc/resolv.conf
    - text: search {{ grains['domain'] }}
{% endif %}

# set the hostname and FQDN name in /etc/hosts
# this is not needed if a proper DNS server is in place, but when using avahi this
# might not be the case. The script tries to to use real IP addresses in order not
# to break round-robin DNS resolution and only uses 127.0.1.1 as a last resort.
{% if grains['use_avahi'] %}
hosts_file_hack:
  cmd.script:
    - name: salt://default/set_ip_in_etc_hosts.py
    {% if grains.get('ipv6')['enable'] %}
    - args: "{{ grains['hostname'] }} {{ grains['domain'] }}"
    {% else %}
    - args: "--no-ipv6 {{ grains['hostname'] }} {{ grains['domain'] }}"
    {% endif %}
    - template: jinja
{% endif %}
