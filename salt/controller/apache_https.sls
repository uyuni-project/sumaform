{% set doc_root = '/root/spacewalk/testsuite' %}
{% set server_name = grains.get('fqdn') or grains.get('ipv4') | first %}

# Ensure Apache is stopped on host (ports will be used by container)
apache2_service_stopped:
  service.dead:
    - name: apache2
    - enable: False

# Install Apache SSL package (needed for certificate generation tools on host)
apache2_ssl_package:
  pkg.installed:
    - name: apache2-mod_nss

# Generate Self-Signed Certificate (Mounted into container)
self_signed_cert:
  cmd.run:
    - name: |
        mkdir -p /etc/apache2/ssl.crt
        install -d -m 700 /etc/apache2/ssl.key
        umask 077
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/apache2/ssl.key/selfsigned.key \
        -out /etc/apache2/ssl.crt/selfsigned.crt \
        -subj '/CN={{ server_name }}/O=Controller/OU=Testsuite'
        chmod 600 /etc/apache2/ssl.key/selfsigned.key
    - unless: test -f /etc/apache2/ssl.crt/selfsigned.crt
    - require:
        - pkg: apache2_ssl_package

# Manage the Python Script file (Mounted into container)
https_python_script_file:
  file.managed:
    - name: /usr/local/lib/https_server.py
    - source: salt://controller/https_server.py
    - user: root
    - group: root
    - mode: 755
