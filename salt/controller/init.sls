include:
  - repos
  - controller.apache_https

# Install Podman
podman_pkg:
  pkg.installed:
    - name: podman

# SSH Keys (Mounted into container later)
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

# Git Config (Mounted into container later)
git_config:
  file.append:
    - name: /root/.netrc
    - text: |
        {%- if grains.get("git_username") and grains.get("git_password") %}
        machine github.com
        login {{ grains.get("git_username") }}
        password {{ grains.get("git_password") }}
        protocol https
        {%- endif %}
    - makedirs: True

# Clone Repository on Host (Mounted into container)
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
        - file: git_config
        - pkg: podman_pkg # Ensure git is available (usually in base or via repos)

# Environment Variables (Mounted into container)
# We save this to a separate file to be sourced inside the container
testsuite_env_vars:
  file.managed:
    - name: /root/salt_env.sh
    - source: salt://controller/bashrc
    - template: jinja
    - user: root
    - group: root
    - mode: 755

# Deploy the updated run-testsuite script
cucumber_run_script:
  file.managed:
    - name: /usr/bin/run-testsuite
    - source: salt://controller/run-testsuite
    - template: jinja
    - user: root
    - group: root
    - mode: 755

# Chrome Cert DB directory on host (Mounted into container)
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

# Run the Controller Container
# We use network mode 'host' so it shares the VM's IP and networking visibility
uyuni_controller_container:
  cmd.run:
    - name: |
        podman run -d \
          --name uyuni-controller \
          --network host \
          --privileged \
          -v /root/spacewalk:/root/spacewalk \
          -v /root/.ssh:/root/.ssh \
          -v /root/.netrc:/root/.netrc \
          -v /root/salt_env.sh:/root/salt_env.sh \
          -v /root/.pki:/root/.pki \
          -v /etc/apache2/ssl.crt:/etc/apache2/ssl.crt \
          -v /etc/apache2/ssl.key:/etc/apache2/ssl.key \
          -v /usr/local/lib/https_server.py:/usr/local/lib/https_server.py \
          ghcr.io/uyuni-project/uyuni/ci-test-controller-dev:master
    - unless: podman inspect uyuni-controller >/dev/null 2>&1
    - require:
        - pkg: podman_pkg
        - cmd: spacewalk_git_repository
        - file: testsuite_env_vars
        - cmd: self_signed_cert  # From apache_https.sls

# Configure Container Environment (Source variables, install missing NPM/Gems)
configure_container:
  cmd.run:
    - name: |
        # Append sourcing of salt env vars to container bashrc
        podman exec uyuni-controller bash -c "grep -q 'salt_env.sh' /root/.bashrc || echo 'source /root/salt_env.sh' >> /root/.bashrc"

        # Ensure gems are up to date with the cloned repo
        podman exec -w /root/spacewalk/testsuite uyuni-controller bundle install
    - require:
        - cmd: uyuni_controller_container

# Start the HTTPS Testsuite Server inside the container
start_https_service_container:
  cmd.run:
    - name: podman exec -d uyuni-controller python3 /usr/local/lib/https_server.py
    - require:
        - cmd: configure_container