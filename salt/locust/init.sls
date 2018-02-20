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
        ExecStart=/usr/bin/locust --host=https://{{ grains['server'] }} --locustfile=/root/locustfile.py --port 80

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
