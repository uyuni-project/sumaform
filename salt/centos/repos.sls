{% if grains['os'] == 'CentOS'%}
centos-salt-pkg:
  file.managed:
    - name: /etc/yum.repos.d/SUSE_RES-7_Update_standard.repo
    - source: salt://centos/repos.d/SUSE_RES-7.repo
    - template: jinja

deploy_galaxy_key:
  file.managed:
    - name: /tmp/galaxy.key
    - source: salt://default/galaxy.key

trust_galaxy_key:
  cmd.wait:
    - name: rpm --import /tmp/galaxy.key
    - watch:
      - file: deploy_galaxy_key

refresh-up2date-repos:
  cmd.run:
    - name: yum -y update
    - require:
      - cmd: trust_galaxy_key
{% endif %}
