{% set doc_root = '/root/spacewalk/testsuite' %}
{% set server_name = grains.get('fqdn') or grains.get('ipv4') | first %}

# Ensure Apache is stopped (since Python is taking port 443)
apache2_service_stopped:
  service.dead:
    - name: apache2
    - enable: False

apache2_ssl_package:
{% if grains['os_family'] == 'Suse' %}
  # Install Apache SSL package (needed for certificate generation tools)
  pkg.installed:
    - name: apache2-mod_nss
{% else %}
  # Enable SSL module (needed for certificate generation tools)
  cmd.run:
    - name: a2enmod ssl
{% endif %}

# Generate Self-Signed Certificate (used by Python script)
self_signed_cert:
  cmd.run:
    - name: |
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
{% if grains['os_family'] == 'Suse' %}
        -keyout /etc/apache2/ssl.key/selfsigned.key \
        -out /etc/apache2/ssl.crt/selfsigned.crt \
{% else %}
        -keyout /etc/ssl/private/selfsigned.key \
        -out /etc/ssl/certs/selfsigned.crt \
{% endif %}
        -subj '/CN={{ server_name }}/O=Controller/OU=Testsuite'
{% if grains['os_family'] == 'Debian' %}
    - unless: test -f /etc/ssl/certs/selfsigned.crt
    - require:
      - cmd: apache2_ssl_package
{% else %}
    - unless: test -f /etc/apache2/ssl.crt/selfsigned.crt
    - require:
      - pkg: apache2_ssl_package
{% endif %}

# Manage the Python Script file
https_python_script_file:
  file.managed:
    - name: /usr/local/lib/https_server.py
    - source: salt://controller/https_server.py
    - user: root
    - group: root
    - mode: 755

# Manage the systemd service unit file
https_testsuite_service_file:
  file.managed:
    - name: /etc/systemd/system/https_testsuite.service
    - source: salt://controller/https_testsuite.service
    - user: root
    - group: root
    - mode: 600
    - require:
      - file: https_python_script_file
      - service: apache2_service_stopped

# Run the new HTTPS service
https_testsuite_service:
  service.running:
    - name: https_testsuite
    - enable: true
    - require:
      - file: https_testsuite_service_file
      - cmd: self_signed_cert
      - cmd: spacewalk_git_repository
