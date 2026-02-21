{% set doc_root = '/root/spacewalk/testsuite' %}
{% set server_name = grains.get('fqdn') or grains.get('ipv4') | first %}

# Ensure Apache is installed
apache2_installed:
  pkg.installed:
    - name: apache2

# Ensure Apache is stopped (since Python is taking port 443)
apache2_service_stopped:
  service.dead:
    - name: apache2
    - enable: False
    - require:
      - pkg: apache2_installed

apache2_ssl_package:
{% if grains['os_family'] == 'Suse' %}
  # Install Apache SSL package (needed for certificate generation tools)
  pkg.installed:
    - name: apache2-mod_nss
    - require:
      - pkg: apache2_installed
{% else %}
  # Enable SSL module (needed for certificate generation tools)
  cmd.run:
    - name: a2enmod ssl
    - require:
      - pkg: apache2_installed
{% endif %}

# Generate Self-Signed Certificate (used by Python script)
{% set ssl_dir = '/etc/apache2' if grains['os_family'] == 'Suse' else '/etc/ssl' %}
{% set cert_path = ssl_dir ~ '/ssl.crt/selfsigned.crt' if grains['os_family'] == 'Suse' else ssl_dir ~ '/certs/selfsigned.crt' %}
{% set key_path = ssl_dir ~ '/ssl.key/selfsigned.key' if grains['os_family'] == 'Suse' else ssl_dir ~ '/private/selfsigned.key' %}

self_signed_cert:
  cmd.run:
    - name: >
        openssl req -x509 -nodes -days 365 -newkey rsa:2048
        -keyout {{ key_path }}
        -out {{ cert_path }}
        -subj '/CN={{ server_name }}/O=Controller/OU=Testsuite'
    - unless: test -f {{ cert_path }}
    - require:
      {% if grains['os_family'] == 'Suse' %}
        - pkg: apache2_ssl_package
      {% else %}
        - cmd: apache2_ssl_package
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
