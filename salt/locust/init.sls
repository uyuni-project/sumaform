include:
  - default

mozilla_certificates:
  pkg.installed:
    - name: ca-certificates-mozilla
    - require:
      - sls: default

pip_prerequisites:
  pkg.installed:
    - pkgs:
      - gcc
      - python-devel
      - python-pyzmq-devel
      - git-core
      - python-pip

setuptools:
  pip.installed:
      - name: setuptools == 39.2.0
      - require:
        - pkg: pip_prerequisites

greenlet:
  pip.installed:
      - name: greenlet
      - require:
        - pkg: pip_prerequisites

locustio:
  pip.installed:
    - name: locustio == 0.8.1
    - require:
      - pip: setuptools
      - pip: greenlet

prometheus_client:
  pip.installed:
   - name: prometheus-client == 0.1.1
   - require:
     - pkg: pip_prerequisites
     - pkg: mozilla_certificates

locustfile:
  file.decode:
    - name: /root/locustfile.py
    - encoding_type: base64
    - encoded_data: {{ grains['locust_file'] }}

locust_service:
  file.managed:
    - name: /etc/systemd/system/locust.service
    - contents: |
        [Unit]
        Description=locust

        [Service]
        Environment=SERVER_USERNAME={{ grains.get('server_username') | default('admin', true) }}
        Environment=SERVER_PASSWORD={{ grains.get('server_password') | default('admin', true) }}
        ExecStart=/usr/bin/locust --host=https://{{ grains['server'] }} \
                                  --locustfile=/root/locustfile.py \
                                  --logfile=/var/log/locust.log \
                                  {% if not grains.get('locust_master_host') and grains.get('locust_slave_count', 0) > 0 -%}
                                  --master \
                                  --expect-slaves={{ grains['locust_slave_count'] }} \
                                  --port 80
                                  {% elif grains['locust_master_host'] -%}
                                  --slave \
                                  --master-host={{ grains['locust_master_host'] }} \
                                  {% else -%}
                                  --port 80
                                  {% endif %}

        [Install]
        WantedBy=multi-user.target
    - require:
      - pip: locustio
  service.running:
    - name: locust
    - enable: True
    - require:
      - file: locust_service
      - file: locustfile
    - watch:
      - file: locustfile

locust_runner:
  file.managed:
    - name: /usr/bin/run-locust
    - source: salt://locust/run-locust.py
    - template: jinja
    - mode: 755

locust_exporter:
  file.managed:
    - name: /usr/bin/locust-exporter
    - source: salt://locust/locust-exporter.py
    - template: jinja
    - mode: 755

locust_exporter_service:
  file.managed:
    - name: /etc/systemd/system/locust_exporter.service
    - contents: |
        [Unit]
        Description=locust_exporter

        [Service]
        ExecStart=/usr/bin/locust-exporter 9500 localhost:80

        [Install]
        WantedBy=multi-user.target
    - require:
      - service: locust_service
      - file: locust_exporter
  service.running:
    - name: locust_exporter
    - enable: True
    - require:
      - file: locust_exporter_service
      - file: locust_exporter
    - watch:
      - file: locust_exporter
