init-control-node-repo:
# control node is always sles-12-sp1, so stay true to KISS.
  cmd.run:
    - name: |
        zypper addrepo http://download.suse.de/ibs/Devel:/Galaxy:/ruby:/test/SLE_12/Devel:Galaxy:ruby:test.repo
        zypper addrepo http://download.suse.de/ibs/SUSE:/SLE-12:/Update/standard/SUSE:SLE-12:Update.repo
        zypper addrepo http://download.suse.de/ibs/Devel:/SLEnkins/SLE_12_SP1/Devel:SLEnkins.repo
        zypper addrepo http://dist.suse.de/install/SLP/SLE-12-SP1-Server-GM/x86_64/DVD1/ sles-12-sp1
        zypper addrepo http://download.suse.de/install/SLP/SLE-12-SP1-SDK-GM/x86_64/DVD1/ SDK
        zypper -n --gpg-auto-import-keys ref


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
      - ruby2.1-rubygem-builder
      - rubygem-owasp_zap
      - rubygem-cliver
      - rubygem-twopence
gems-installation:

  gem.installed:
    - names:
       - rake
       - syntax
       - poltergeist
       - lavanda
       - highline

git-download-cucumber:
  cmd.run:
        - name: git clone -b slenkins https://github.com/SUSE/spacewalk-testsuite-base.git

salt-master:
  service.running: 
    - enable : True

accept-key:
   cmd.run:
    - name: salt-key -A
    - require:
        - salt-master

run-cucumber:
  cmd.run:
    - name: |
         export MINION={{grains['minion']}}; 
         export TESTHOST={{grains['server']}} 
         export CLIENT={{grains['client']}}
         export BROWSER=phantomjs
         cd /root/spacewalk-testsuite-base

