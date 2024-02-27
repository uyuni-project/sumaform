include:
  - repos

ssh_private_key_proxy_containerized:
  file.managed:
    - name: /root/.ssh/id_rsa
    - source: salt://proxy_containerized/id_rsa
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

ssh_public_key_proxy_containerized:
  file.managed:
    - name: /root/.ssh/id_rsa.pub
    - source: salt://proxy_containerized/id_rsa.pub
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

authorized_keys_proxy_containerized:
  file.append:
    - name: /root/.ssh/authorized_keys
    - source: salt://proxy_containerized/id_rsa.pub
    - makedirs: True

ssh_config_proxy_containerized:
  file.managed:
    - name: /root/.ssh/config
    - source: salt://proxy_containerized/config
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

# Note: In our registries we don't have released and not released versions at this point in time
{% if grains.get('container_repository') %}
  {% set container_repository = grains.get('container_repository') %}
{% else %}
  {% if 'uyuni' in grains.get('product_version') %}
    {% set container_repository = 'registry.opensuse.org/systemsmanagement/uyuni/master/containers/uyuni' %}
  {% elif '5.0' in grains.get('product_version') %}
    {% set container_repository = 'registry.suse.de/devel/galaxy/manager/5.0/containers/suse/manager/5.0' %}
  {% else %} # Head
    {% set container_repository = 'registry.suse.de/devel/galaxy/manager/head/containers/suse/manager/5.0' %}
  {% endif %}
{% endif %}

# Useful to setup the proxy through the tests
env_var_bashrc_registry_proxy_httpd_image:
  cmd.run:
    - name: |
        echo "export UYUNI_IMAGES_LOCATION={{ container_repository }}" >> /root/.bashrc
        source /root/.bashrc

{% if 'Micro' not in grains['osfullname'] %}
install_mgr_tools:
  pkg.installed:
    - pkgs:
      - podman
      - mgrpxy
      - mgrctl
{% endif %}

# This will only work if the proxy is part of the cucumber_testsuite module, otherwise the server might not be ready
{% if grains.get('auto_configure') and grains.get('testsuite') and grains.get('first_user_present') %}
generate_configuration_file_from_server:
  cmd.run:
    - name: |
       ssh {{ grains['server'] }} "echo spacewalk > /root/spacewalk"
       ssh {{ grains['server'] }} mgrctl cp /root/spacewalk server:/root/spacewalk
       ssh {{ grains['server'] }} mgrctl exec -- spacecmd --nossl -u {{ grains.get('server_username') | default('admin', true) }} -p {{ grains.get('server_password') | default('admin', true) }} proxy_container_config_generate_cert -- --ca-pass /root/spacewalk -o /root/config.tar.gz {{ grains['hostname'] }}.{{ grains['domain'] }} {{ grains['server'] }} 2048 galaxy-noise@suse.de
       ssh {{ grains['server'] }} mgrctl cp server:/root/config.tar.gz .
       scp {{ grains['server'] }}:config.tar.gz /root/config.tar.gz
       ssh {{ grains['server'] }} rm /root/config.tar.gz
       ssh {{ grains['server'] }} mgrctl exec -ti -- rm /root/config.tar.gz
    - cwd: /root
    - creates: /root/config.tar.gz

install_proxy_container:
  cmd.run:
    - name: |
       mgrpxy install podman /root/config.tar.gz
{% endif %}
