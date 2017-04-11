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
      - firefox-bin
      - apache2-worker
      - phantomjs
      - owasp-zap
      - mozilla-nss
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
      - rubygem-owasp_zap
      - rubygem-cliver
      - ruby2.1-rubygem-rake
      - rubygem-twopence
      - ruby2.1-rubygem-simplecov
      - rubygem-lavanda
      - ruby2.1-rubygem-poltergeist
      - ruby2.1-rubygem-rake
    - require:
      - sls: controller.repos

cucumber_testsuite:
  cmd.run:
    # HACK: work around the lack of skip_verify and enforce_toplevel in archive.extracted before salt 2016.11
    - name: |
        wget -P /root/ https://github.com/SUSE/spacewalk-testsuite-base/archive/{{ grains.get("branch" )}}.zip
        unzip /root/{{ grains.get("branch" )}}.zip -d /root/
        mv /root/spacewalk-testsuite-base-{{ grains.get("branch" )}} /root/spacewalk-testsuite-base
    - creates: /root/spacewalk-testsuite-base

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
