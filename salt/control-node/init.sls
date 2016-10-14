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

binary-install:

  pkg.installed:
    - pkgs:
      - gcc
      - ruby
      - zlib-devel
      - ruby-devel
      - firefox-bin
      - apache2-worker
      - phantomjs
      - owasp-zap
      - mozilla-nss
# this are packaged gems
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

gems-installation:

  gem.installed:
    - names:
       - rake
       - bundler
       - syntax
       - poltergeist
       - lavanda
