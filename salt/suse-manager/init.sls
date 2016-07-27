include:
  - suse-manager.repos
  - suse-manager.firewall
  - suse-manager.postgres
  - suse-manager.pgpool

{% if '2.1' in grains['version'] %}
# remove SLES product release package, it's replaced by SUSE Manager's
sles-release:
  pkg.removed:
    - require:
      - sls: suse-manager.repos
{% endif %}

suse-manager-packages:
  pkg.latest:
    {% if 'head' in grains['version'] %}
    - fromrepo: SUSE-Manager-Head-x86_64-Pool
    - name: patterns-suma_server
    {% elif '3-stable' in grains['version'] %}
    - fromrepo: SUSE-Manager-3.0-x86_64-Pool
    - name: patterns-suma_server
    {% elif '3-nightly' in grains['version'] %}
    - fromrepo: Devel_Galaxy_Manager_3.0
    - name: patterns-suma_server
    {% else %}
    - pkgs:
      - cyrus-sasl-digestmd5
      - perl-TimeDate
      - sm-network-discovery-client
      - smdba
      - spacecmd
      - spacewalk-reports
      - suse-manager-server-release
      - susemanager
      - susemanager-client-config_en-pdf
      - susemanager-install_en-pdf
      - susemanager-manuals_en
      - susemanager-proxy-quick_en-pdf
      - susemanager-reference_en-pdf
      - susemanager-tftpsync
      - susemanager-user_en-pdf
      - timezone
      {% if grains['database'] == 'oracle' %}
      - bc
      - oracle-server
      - spacewalk-oracle
      - susemanager-branding-non-oss
      {% else %}
      - spacewalk-postgresql
      - susemanager-branding-oss
      {% endif %}
    {% endif %}
    - require:
      - sls: suse-manager.repos
      - sls: suse-manager.firewall

/root/setup_env.sh:
  file.managed:
    - source: salt://suse-manager/setup_env.sh
    - template: jinja

suse-manager-setup:
  cmd.run:
    - name: /usr/lib/susemanager/bin/migration.sh -l /var/log/susemanager_setup.log -s
    - creates: /root/.MANAGER_SETUP_COMPLETE
    - user: root
    - require:
      - pkg: suse-manager-packages
      - file: /root/setup_env.sh
      {% if grains['database'] == 'pgpool' %}
      - sls: suse-manager.pgpool
      {% endif %}

remove-motd:
  file.absent:
    - name: /etc/motd
    - require:
      - cmd: suse-manager-setup
