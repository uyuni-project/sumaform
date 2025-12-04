{% set doc_root = '/root/spacewalk/testsuite' %}
{% set server_name = grains.get('fqdn') or grains.get('ipv4') | first %}

install_apache2:
  pkg.installed:
    - pkgs:
        - apache2

# Ensure Apache is stopped (since Python is taking port 443)
apache2_service_stopped:
  service.dead:
    - name: apache2
    - enable: False

# Enable SSL module (needed for certificate generation tools)
apache2_ssl_package:
  cmd.run:
    - name: a2enmod ssl

# Generate Self-Signed Certificate (used by Python script)
self_signed_cert:
  cmd.run:
    - name: |
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/selfsigned.key \
        -out /etc/ssl/certs/selfsigned.crt \
        -subj '/CN={{ server_name }}/O=Controller/OU=Testsuite'
    - unless: test -f /etc/ssl/certs/selfsigned.crt

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
