
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
