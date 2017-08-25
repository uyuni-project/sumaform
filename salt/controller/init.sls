include:
  - controller.repos

ssh_private_key:
  file.managed:
    - name: /root/.ssh/id_rsa
    - source: salt://controller/id_rsa
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

ssh_public_key:
  file.managed:
    - name: /root/.ssh/id_rsa.pub
    - source: salt://controller/id_rsa.pub
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

authorized_keys_controller:
  file.append:
    - name: /root/.ssh/authorized_keys
    - source: salt://controller/id_rsa.pub
    - makedirs: True

virtualhost:
  file.managed:
    - name: /tmp/virtualhostmanager.create.json
    - source: salt://controller/virtualhostmanager.create.json

cucumber_requisites:
  pkg.installed:
    - pkgs:
      - gcc
      - make
      - ruby
      - ruby-devel
      - apache2-worker
      - phantomjs
      - cantarell-fonts
      - git-core
      - wget
      - aaa_base-extras
      - unzip
      # packaged ruby gems
      - ruby2.1-rubygem-bundler
      - rubygem-cucumber
      - twopence
      - rubygem-rack-1_2
      - rubygem-selenium-webdriver
      - rubygem-net-ssh
      - rubygem-websocket-1_0
      - rubygem-websocket-driver
      - ruby2.1-rubygem-jwt
      - rubygem-mime-types
      - ruby2.1-rubygem-builder
      - rubygem-cliver
      - ruby2.1-rubygem-rake
      - rubygem-twopence
      - ruby2.1-rubygem-simplecov
      - ruby2.1-rubygem-poltergeist
      - ruby2.1-rubygem-rake
    - require:
      - sls: controller.repos

cucumber_testsuite:
  git.latest:
    - name: https://github.com/SUSE/spacewalk-testsuite-base
    - target: /root/spacewalk-testsuite-base
    - branch: {{ grains.get("branch") }}
    - rev: {{ grains.get("branch") }}
    - force_reset: True
    - require:
      - pkg: cucumber_requisites

cucumber_run_script:
  file.managed:
    - name: /usr/bin/run-testsuite
    - source: salt://controller/run-testsuite.sh
    - template: jinja
    - user: root
    - group: root
    - mode: 755

testsuite_env_vars:
  file.managed:
    - name: /root/.bashrc
    - source: salt://controller/bashrc
    - template: jinja
    - user: root
    - group: root
    - mode: 755
