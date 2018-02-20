python-pip:
  pkg.installed

locustio:
  pip.installed:
    - name: locustio >= 0.8.0, <= 0.8.1
    - require:
      - pkg: python-pip
      - pkg: locust-prereq

prometheus-clint:
  pip.installed:
   - name: prometheus-client >= 0.1.0, <= 0.1.1
   - require:
     - pkg: python-pip
     - pkg: locust-prereq

locust-prereq:
  pkg.installed:
    - pkgs:
      - gcc
      - python-devel
      - python-pyzmq-devel
      - git-core

locust_config_file:
  file.managed:
    - name: /root/locust_config.yml
    - source: salt://locust/locust_config.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 755
    - force: True

install_locust_file:
  file.decode:
    - name: /root/locustfile.py
    - encoding_type: base64
    - encoded_data: {{ grains['locust_file'] }}
