include:
  - sles.repos
  - control-node.repos

ssh-private-key:
  file.managed:
    - name: /root/.ssh/id_rsa
    - source: salt://control-node/id_rsa
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

ssh-public-key:
  file.managed:
    - name: /root/.ssh/id_rsa.pub
    - source: salt://control-node/id_rsa.pub
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

authorized-keys:
  file.managed:
    - name: /root/.ssh/authorized_keys
    - source: salt://control-node/id_rsa.pub
    - user: root
    - group: root
    - mode: 700

virtualhost:
  file.managed:
    - name: /tmp/virtualhostmanager.create.json
    - source: salt://control-node/virtualhostmanager.create.json

cucumber-requisites:
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
      - rubygem-lavanda
      - ruby2.1-rubygem-poltergeist
      - ruby2.1-rubygem-rake
    - require:
      - sls: control-node.repos

cucumber-testsuite:
  git.latest:
    - name: https://github.com/SUSE/spacewalk-testsuite-base.git
    - rev: slenkins
    - target: /root/spacewalk-testsuite-base

cucumber-run-script:
  file.managed:
    - name: /usr/bin/run-testsuite
    - source: salt://control-node/run-testsuite.sh
    - template: jinja
    - user: root
    - group: root
    - mode: 755
