
# Note: In our registries we don't have released and not released versions at this point in time
{% if grains.get('container_repository') %}
  {% set container_repository = grains.get('container_repository') %}
{% endif %}

{% if grains.get('container_tag') %}
  {% set container_tag = grains.get('container_tag') %}
{% else %}
  # in SUMA this would use most recent version as tag
  {% set container_tag = '' %}
{% endif %}

# Useful to setup the proxy through the tests
config_proxy_containerized:
  file.managed:
    - name: /etc/uyuni/uyuni-tools.yaml
    - contents: |
        {% if container_repository %}
        {% if grains.get('string_registry') | default(false, true) %}
        registry: {{ container_repository }}
        {% else %}
        registry:
          host: {{ container_repository }}
        {% endif %}
        {% endif %}
        httpd:
          {% if grains.get('httpd_container_image') %}
          image: {{ grains.get('httpd_container_image') }}
          {% endif %}
          tag: {{ container_tag }}
        saltBroker:
          {% if grains.get('salt_broker_container_image') %}
          image: {{ grains.get('salt_broker_container_image') }}
          {% endif %}
          tag: {{ container_tag }}
        squid:
          {% if grains.get('squid_container_image') %}
          image: {{ squid_container_image }}
          {% endif %}
          tag: {{ container_tag }}
        ssh:
          {% if grains.get('ssh_container_image') %}
          image: {{ grains.get('ssh_container_image') }}
          {% endif %}
          tag: {{ container_tag }}
        tftpd:
          {% if grains.get('tftpd_container_image') %}
          image: {{ grains.get('tftpd_container_image') }}
          {% endif %}
          tag: {{ container_tag }}
    - makedirs: True


{% if 'Micro' not in grains['osfullname'] %}
install_mgr_tools:
  pkg.installed:
    - pkgs:
      - podman
      - mgrpxy

{% if grains['osfullname'] == 'SLES' %}
ca_suse:
  pkg.installed:
    - pkgs:
      - ca-certificates-suse
{% endif %}
{% endif %}

# This will only work if the proxy is part of the cucumber_testsuite module, otherwise the server might not be ready
{% if grains.get('auto_configure') and grains.get('testsuite') %}
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

{% set runtime = grains.get('container_runtime') | default('podman', true) %}
install_proxy_container:
  cmd.run:
    - name: |
       mgrpxy install {{ runtime }} /root/config.tar.gz
{% endif %}
