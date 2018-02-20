pip:
  pkg.installed:
    - name: python-pip

locust_prerequisites:
  pkg.installed:
    - pkgs:
      - gcc
      - python-devel
      - python-pyzmq-devel
      - git-core

locustio:
  pip.installed:
    - name: locustio == 0.8.1
    - require:
      - pkg: pip
      - pkg: locust_prerequisites

prometheus_client:
  pip.installed:
   - name: prometheus-client == 0.1.1
   - require:
     - pkg: pip
     - pkg: locust_prerequisites

install_locust_file_template:
  file.decode:
    - name: /root/locustfile.jinja.py
    - encoding_type: base64
    - encoded_data: {{ grains['locust_file'] }}

install_locust_file:
  file.managed:
    - name: /root/locustfile.py
    - source: /root/locustfile.jinja.py
    - template: jinja
    - user: root
    - group: root
    - mode: 755
    - require:
     - file: install_locust_file_template
