include:
  - minion.testsuite
  - centos.repos
  - client.repos

minion:
  pkg.installed:
    - name: salt-minion
    - require:
{% if grains['os'] == 'CentOS'%}
      - sls: centos.repos
{% elif grains['os'] == 'SUSE' %}
      - sls: client.repos
{% endif %}
  service.running:
    - name: salt-minion
    - enable: True
    - watch:
      - pkg: salt-minion
{% if grains['for-development-only'] %}
      - file: master-configuration
{% endif %}


{% if grains['for-development-only'] %}

master-configuration:
  file.managed:
    - name: /etc/salt/minion.d/master.conf
    - contents: |
        master: {{grains['server']}}
    - require:
        - pkg: salt-minion

{% endif %}
