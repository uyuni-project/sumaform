include:
  - sles.repos
  - control-node.repos

/root/.ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 700

ssh-setup:
  file.managed:
      - name: /root/.ssh/id_rsa
      - source: salt://control-node/id_rsa
      - user: root
      - group: root
      - mode : 600

ssh-pubkey:
  file.managed:
      - name: /root/.ssh/id_rsa.pub
      - source: salt://control-node/id_rsa.pub

binary-install:

  pkg.installed:
    - pkgs:
      - gcc
      - make
      - ruby
      - salt-master
      - zlib-devel
      - ruby-devel
      - firefox-bin
      - apache2-worker
      - phantomjs
      - owasp-zap
      - mozilla-nss
      - git-core
      # packaged ruby-gems
      - ruby2.1-rubygem-bundler
      - rubygem-cucumber
      - rubygem-syntax
      - twopence
      - rubygem-selenium-webdriver
      - ruby2.1-rubygem-poltergeist
      - rubygem-rack-1_2
      - rubygem-net-ssh
      - rubygem-websocket-1_0
      - rubygem-websocket-driver
      - ruby2.1-rubygem-jwt
      - rubygem-mime-types
      - ruby2.1.rubygem-builder
      - rubygem-owasp_zap
      - rubygem-cliver
      - rubygem-twopence
    - require:
      - sls: control-node.repos

gems-installation:
  gem.installed:
    - names:
       - rake
       - syntax
       - poltergeist
       - lavanda
       - highline

# clone the cucumber suite
https://github.com/SUSE/spacewalk-testsuite-base.git:
  git.latest:
    - rev: slenkins
    - target: /root/spacewalk-testsuite-base
