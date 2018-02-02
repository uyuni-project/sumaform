python-pip:
  pkg.installed

locustio:
  pip.installed:
    - name: locustio >= 0.8.0, <= 0.8.1
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

spacewalk_git_repository_locust:
  cmd.run:
    - name: git clone --depth 1 https://github.com/SUSE/spacewalk -b Manager /root/spacewalk
    - require:
      - file: netrc_mode_locust

netrc_mode_locust:
  file.managed:
    - name: ~/.netrc
    - user: root
    - group: root
    - mode: 600
    - replace: False
    - require:
      - file: git_config_locust

git_config_locust:
  file.append:
    - name: ~/.netrc
    - text:
      - machine github.com
      - login {{ grains.get("git_username") }}
      - password {{ grains.get("git_password") }}
      - protocol https

locust_config_file_for_test_production:
  file.managed:
    - name: /root/spacewalk/susemanager-utils/performance/locust/locust_config.yml
    - source: salt://locust/locust_config.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 755 
    - force: True
    - require:
      - cmd: spacewalk_git_repository_locust

locust_config_file_for_minimal_example:
  file.managed:
    - name: /root/locust_config.yml
    - source: salt://locust/locust_config.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 755 
    - force: True

simple_locust_example:
  file.managed:
    - name: /root/simple_locust_example.py
    - source: salt://locust/simple_locust_example.py
    - template: jinja
    - user: root
    - group: root
    - mode: 755 
    - force: True

install_locust_file:
  file.decode:
    - name: /root/user_custom_locustfile.py
    - encoding_type: base64
    - encoded_data: {{ grains['locust_file'] }}
