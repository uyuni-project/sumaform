include:
  - controller.apache_https

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

install_npm:
  pkg.installed:
    - name: npm

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
        git checkout
    - creates: /root/spacewalk
    - require:
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

ssh_config:
  file.managed:
    - name: /root/.ssh/config
    - source: salt://controller/ssh_config
    - template: jinja
    - user: root
    - group: root
    - mode: 755

extra_pkgs:
  pkg.installed:
    - pkgs:
      - screen
      - xauth
      - libnss3-tools
      - nodejs

# needed together with the `xauth` package for debugging with chromedriver in non-headlesss mode with `export DEBUG=1`
create_xauthority_file:
  cmd.run:
   - name: touch /root/.Xauthority

create_nss_db:
  cmd.run:
    - name: |
        mkdir -p /root/.pki/nssdb
        certutil -N -d /root/.pki/nssdb --empty-password
    - creates: /root/.pki/nssdb/cert8.db
    - require:
        - pkg: extra_pkgs

install_nvm:
  cmd.run:
    - name: |
        wget -q -O- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

install_node:
  cmd.run:
    - name: |
        export NVM_DIR="/root/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install node
    - require:
        - cmd: install_nvm

install_npm_deps:
  cmd.run:
    - name: |
        export NVM_DIR="/root/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        cd /root/spacewalk
        npm install
    - require:
        - cmd: install_node

install_playwright:
  cmd.run:
    - name: |
        export NVM_DIR="/root/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        cd /root/spacewalk
        npx playwright install
        npx playwright install-deps
    - require:
        - cmd: install_npm_deps

load_bashrc:
  cmd.run:
    - name: source /root/.bashrc
    - require:
        - cmd: install_playwright
