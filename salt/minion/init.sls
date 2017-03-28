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
{% if grains['for_development_only'] %}
      - file: master_configuration
{% endif %}


{% if grains['for_development_only'] %}

master_configuration:
  file.managed:
    - name: /etc/salt/minion.d/master.conf
    - contents: |
        master: {{grains['server']}}
    - require:
        - pkg: salt-minion

{% endif %}
