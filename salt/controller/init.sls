include:
  - repos

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
      - wget
      - ruby
      - ruby-devel
      - autoconf
      - ca-certificates-mozilla
      - automake
      - libtool
      - apache2-worker
      - cantarell-fonts
      - git-core
      - wget
      - aaa_base-extras
      - zlib-devel
      - libxslt-devel
      - mozilla-nss-tools
      # packaged ruby gems
      - ruby2.1-rubygem-bundler
      - twopence
      - rubygem-twopence
    - require:
      - sls: repos

# HACK: currently we need this exact version
phantomjs_2.0_cucumber_repo:
  pkg.installed:
  - name: phantomjs
  - version: 2.0.0

chromium_fixed_version:
  pkg.installed:
  - name: chromium
  - version: 64.0.3282.167

chromedriver_fixed_version:
  pkg.installed:
  - name: chromedriver
  - version: 64.0.3282.167

create_syslink_for_chromedriver:
  file.symlink:
    - name: /usr/bin/chromedriver
    - target: /usr/lib64/chromium/chromedriver

install_gems_via_bundle:
  cmd.run:
    - name: bundle.ruby2.1 install --gemfile /root/spacewalk/testsuite/Gemfile
    - require:
      - pkg: cucumber_requisites
      - cmd: spacewalk_git_repository

spacewalk_git_repository:
  cmd.run:
    - name: git clone --depth 1 https://github.com/SUSE/spacewalk -b {{ grains.get("branch") }} /root/spacewalk
    - creates: /root/spacewalk
    - require:
      - pkg: cucumber_requisites
      - file: netrc_mode

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

extra_pkgs:
  pkg.installed:
    - pkgs:
      - screen
    - require:
      - sls: repos

git_config:
  file.append:
    - name: ~/.netrc
    - text:
      - machine github.com
      - login {{ grains.get("git_username") }}
      - password {{ grains.get("git_password") }}
      - protocol https

netrc_mode:
  file.managed:
    - name: ~/.netrc
    - user: root
    - group: root
    - mode: 600
    - replace: False
    - require:
      - file: git_config

chrome_certs:
  file.directory:
    - user:  root
    - name:  /root/.pki/nssdb
    - group: users
    - mode:  755
    - makedirs: True

google_cert_db:
  cmd.run:
   - name: certutil -d sql:/root/.pki/nssdb -N --empty-password
   - require:
     - file: chrome_certs
