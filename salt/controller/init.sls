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
      - aaa_base-extras
      - zlib-devel
      - libxslt-devel
      - mozilla-nss-tools
      # packaged ruby gems
      - ruby2.5-rubygem-bundler
      - twopence
      - python-twopence
      - twopence-devel
      - twopence-shell-client
      - twopence-test-server
      - rubygem-twopence
    - require:
      - sls: repos

install_chromium:
  pkg.installed:
  - name: chromium

install_chromedriver:
  pkg.installed:
  - name: chromedriver

create_syslink_for_chromedriver:
  file.symlink:
    - name: /usr/bin/chromedriver
    - target: /usr/lib64/chromium/chromedriver

install_gems_via_bundle:
  cmd.run:
    - name: bundle.ruby2.5 install --gemfile Gemfile
    - cwd: /root/spacewalk/testsuite
    - require:
      - pkg: cucumber_requisites
      - cmd: spacewalk_git_repository

install_npm:
  pkg.installed:
    - name: npm8

# https://github.com/gkushang/cucumber-html-reporter
#install_cucumber_html_reporter_via_npm:
#  cmd.run:
#    - name: npm install cucumber-html-reporter@5.2.0 --save-dev
#    - require:
#      - pkg: install_npm

# Temporary using a personal fork until this commit is publicly released
install_cucumber_html_reporter_via_git:
  cmd.run:
    - name: npm install github:srbarrios/cucumber-html-reporter#788ef843796aa76bfa33bb4dc4de04eb7c00c0ed
    - require:
      - pkg: install_npm

fix_cucumber_html_reporter_style:
  file.append:
    - name: /root/node_modules/cucumber-html-reporter/templates/_common/bootstrap.hierarchy/style.css
    - text: |
        .container {
            width: 100%;
        }
    - require:
      - cmd: install_cucumber_html_reporter_via_git

git_config:
  file.append:
    - name: ~/.netrc
    - text: |
{%- if grains.get("git_username") and grains.get("git_password") %}
        machine github.com
        login {{ grains.get("git_username") }}
        password {{ grains.get("git_password") }}
        protocol https
{%- endif %}

netrc_mode:
  file.managed:
    - name: ~/.netrc
    - user: root
    - group: root
    - mode: 600
    - replace: False
    - require:
      - file: git_config

spacewalk_git_repository:
  cmd.run:
{%- set url = grains.get('git_repo') | default('default', true) %}
{%- set branch = grains.get('branch') | default('master', true) %}
{%- if url == 'default' %}
{%-   if branch == 'master' %}
{%-     set url = 'https://github.com/uyuni-project/uyuni.git' %}
{%-   else %}
{%-     set url = 'https://github.com/SUSE/spacewalk.git' %}
{%-   endif %}
{%- endif %}
    - name: |
        git clone --depth 100 --no-checkout --branch {{ branch }} {{ url }} /root/spacewalk
        cd /root/spacewalk
        git sparse-checkout init --cone
        git sparse-checkout set testsuite
        git checkout
    - creates: /root/spacewalk
    - require:
      - pkg: cucumber_requisites
      - file: netrc_mode

cucumber_run_script:
  file.managed:
    - name: /usr/bin/run-testsuite
    - source: salt://controller/run-testsuite
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
   - creates: /root/.pki/nssdb

http_testsuite_service_file:
  file.managed:
    - name: /etc/systemd/system/http_testsuite.service
    - source: salt://controller/http_testsuite.service
    - user: root
    - groop: root
    - mode: 600

http_testsuite_service:
  service.running:
    - name: http_testsuite
    - enable: true
    - require:
      - file: http_testsuite_service_file
