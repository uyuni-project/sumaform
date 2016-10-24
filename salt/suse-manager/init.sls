include:
  - suse-manager.repos
  - suse-manager.firewall
  - suse-manager.postgres
  - suse-manager.pgpool
  - suse-manager.tomcat
  - suse-manager.taskomatic
  - suse-manager.rhn
  - suse-manager.iss

{% if '2.1' in grains['version'] %}
# remove SLES product release package, it's replaced by SUSE Manager's
sles-release:
  pkg.removed:
    - require:
      - sls: suse-manager.repos
{% endif %}

allow-vendor-changes:
  file.managed:
    - name: /etc/zypp/vendors.d/suse
    - contents: |
        [main]
        vendors = SUSE,obs://build.suse.de/Devel:Galaxy:Manager

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
      - file: allow-vendor-changes

salt:
  pkg.latest:
    - require:
      - file: allow-vendor-changes

environment-setup-script:
  file.managed:
    - name: /root/setup_env.sh
    - source: salt://suse-manager/setup_env.sh
    - template: jinja

suse-manager-setup:
  cmd.run:
    - name: /usr/lib/susemanager/bin/migration.sh -l /var/log/susemanager_setup.log -s
    - creates: /root/.MANAGER_SETUP_COMPLETE
    - user: root
    - require:
      - pkg: suse-manager-packages
      - file: environment-setup-script
      {% if grains['database'] == 'pgpool' %}
      - sls: suse-manager.pgpool
      {% endif %}

ca-cert-checksum:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT > /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - creates: /srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT.sha512
    - require:
      - cmd: suse-manager-setup

remove-motd:
  file.absent:
    - name: /etc/motd
    - require:
      - cmd: suse-manager-setup

# add files/conf to the server for the cucumber suite.

/root/.ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 700

ssh-key-server:
  file.managed:
    - name: /root/.ssh/authorized_keys
    - source: salt://suse-manager/authorized_keys

anaconda:
  file.managed:
    - name: /root/anaconda-18.37.11-1.fc18.x86_64.rpm
    - source: salt://suse-manager/test-server/anaconda-18.37.11-1.fc18.x86_64.rpm

subscription-tools:
  file.managed:
    - name: /root/subscription-tools-1.0-0.noarch.rpm
    - source: salt://suse-manager/test-server/subscription-tools-1.0-0.noarch.rpm

/root/install:
  file.recurse:
    - source: salt://suse-manager/test-server/install

/srv/www/htdocs/pub/:
  file.recurse:
    - source: salt://suse-manager/test-server/pub

/tmp/vCenter.json:
  file.managed:
    - source: salt://suse-manager/test-server/vCenter.json

# modify cobbler to be executed from remote-machines.. 

config-cobbler:
    service:
    - name : cobblerd.service
    - running
    - enable: True
    - watch : 
      - file : /etc/cobbler/settings

    file.replace:
    - name: /etc/cobbler/settings
    - pattern: redhat_management_permissive: 0
    - repl: redhat_management_permissive: 1
