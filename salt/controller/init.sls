include:
  - repos

ssh_private_key:
  file.managed:
    - name: /root/.ssh/id_ed25519
    - source: salt://controller/id_ed25519
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

ssh_public_key:
  file.managed:
    - name: /root/.ssh/id_ed25519.pub
    - source: salt://controller/id_ed25519.pub
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

authorized_keys_controller:
  file.append:
    - name: /root/.ssh/authorized_keys
    - source: salt://controller/id_ed25519.pub
    - makedirs: True

cucumber_requisites:
  pkg.installed:
    - pkgs:
      - gcc
      - make
      - wget
      - libssh-devel
      - python-devel
      - ruby3.3
      - ruby3.3-devel
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
      - postgresql-devel
      - unzip
    - require:
      - sls: repos

/usr/bin/ruby:
  file.symlink:
    - target: /usr/bin/ruby.ruby3.3
    - force: True

/usr/bin/gem:
  file.symlink:
    - target: /usr/bin/gem.ruby3.3
    - force: True

/usr/bin/irb:
  file.symlink:
    - target: /usr/bin/irb.ruby3.3
    - force: True

ruby_set_rake_version:
  cmd.run:
    - name: update-alternatives --set rake /usr/bin/rake.ruby.ruby3.3

ruby_set_bundle_version:
  cmd.run:
    - name: update-alternatives --set bundle /usr/bin/bundle.ruby.ruby3.3

ruby_set_rdoc_version:
  cmd.run:
    - name: update-alternatives --set rdoc /usr/bin/rdoc.ruby.ruby3.3

ruby_set_ri_version:
  cmd.run:
    - name: update-alternatives --set ri /usr/bin/ri.ruby.ruby3.3

install_chromium:
  pkg.installed:
  - name: chromium

install_chromedriver:
  pkg.installed:
  - name: chromedriver

create_syslink_for_chromedriver:
  file.symlink:
    - name: /usr/bin/chromedriver
    - target: ../lib64/chromium/chromedriver
    - force: True

install_npm:
  pkg.installed:
    - name: npm-default

install_gems_via_bundle:
  cmd.run:
    - name: bundle.ruby3.3 install --gemfile Gemfile
    - cwd: /root/spacewalk/testsuite
    - require:
      - pkg: cucumber_requisites
      - cmd: spacewalk_git_repository

# https://github.com/gkushang/cucumber-html-reporter
install_cucumber_html_reporter_via_npm:
  cmd.run:
    - name: npm install cucumber-html-reporter@7.2.0 --save-dev
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
      - cmd: install_cucumber_html_reporter_via_npm

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
      - xauth
    - require:
      - sls: repos

# needed together with the `xauth` package for debugging with chromedriver in non-headlesss mode with `export DEBUG=1`
create_xauthority_file:
  cmd.run:
   - name: touch /root/.Xauthority

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
