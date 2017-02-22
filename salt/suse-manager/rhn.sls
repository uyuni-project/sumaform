{% if grains['for-development-only'] %}

include:
  - suse-manager

incomplete-package-import-reposync:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: incomplete_package_import = 1
    - require:
      - sls: suse-manager

{% if 'stable' not in grains['version'] %}

browser-side-less-configuration:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: development_environment = true
    - require:
      - sls: suse-manager
  pkg.installed:
    - pkgs:
      - susemanager-frontend-libs-devel
      - spacewalk-branding-devel
    {% if '2.1' in grains['version'] %}
    - fromrepo: Devel_Galaxy_Manager_2.1
    {% endif %}
    - require:
      - sls: suse-manager

{% endif %}

create-first-user:
  http.query:
    - method: POST
    {% if '2.1' in grains['version'] %}
    - name: https://localhost/rhn/newlogin/CreateFirstUserSubmit.do
    - match: For details on SUSE Manager, please visit our website
    - data: "login=admin&\
             desiredpassword=admin&\
             desiredpasswordConfirm=admin&\
             firstNames=Administrator&\
             lastName=McAdmin&\
             email=admin%40admin.admin&\
             account_type=create_sat"
    {% else %}
    - name: https://localhost/rhn/newlogin/CreateFirstUser.do
    - match: Discover a new way of managing your servers
    - data: "submitted=true&\
             orgName=Novell&\
             login=admin&\
             desiredpassword=admin&\
             desiredpasswordConfirm=admin&\
             email=admin%40admin.admin&\
             firstNames=Administrator&\
             lastName=McAdmin"
    {% endif %}
    - verify_ssl: False
    - unless: spacecmd -u admin -p admin user_list | grep -x admin
    - require:
      - sls: suse-manager

create-empty-channel:
  cmd.run:
    - name: spacecmd -u admin -p admin -- softwarechannel_create --name testchannel -l testchannel -a x86_64
    - unless: spacecmd -u admin -p admin softwarechannel_list | grep -x testchannel
    - require:
      - http: create-first-user

create-activation-key:
  cmd.run:
    {% if '2.1' in grains['version'] %}
    - name: spacecmd -u admin -p admin -- activationkey_create -n DEFAULT -b testchannel -e provisioning_entitled
    {% else %}
    - name: spacecmd -u admin -p admin -- activationkey_create -n DEFAULT -b testchannel
    {% endif %}
    - unless: spacecmd -u admin -p admin activationkey_list | grep -x 1-DEFAULT
    - require:
      - cmd: create-empty-channel

create-bootstrap-script:
  cmd.run:
    - name: rhn-bootstrap --activation-keys=1-DEFAULT --no-up2date
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap.sh
    - require:
      - cmd: create-activation-key

create-bootstrap-script-md5:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/bootstrap/bootstrap.sh > /srv/www/htdocs/pub/bootstrap/bootstrap.sh.sha512
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap.sh.sha512
    - require:
      - cmd: create-bootstrap-script

private-ssl-key:
  file.copy:
    - name: /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY
    - source: /root/ssl-build/RHN-ORG-PRIVATE-SSL-KEY
    - mode: 644
    - require:
      - cmd: suse-manager-setup

private-ssl-key-checksum:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY > /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY.sha512
    - creates: /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY.sha512
    - require:
      - file: private-ssl-key

ca-configuration:
  file.copy:
    - name: /srv/www/htdocs/pub/rhn-ca-openssl.cnf
    - source: /root/ssl-build/rhn-ca-openssl.cnf
    - mode: 644

ca-configuration-checksum:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/rhn-ca-openssl.cnf > /srv/www/htdocs/pub/rhn-ca-openssl.cnf.sha512
    - creates: /srv/www/htdocs/pub/rhn-ca-openssl.cnf.sha512
    - require:
      - file: ca-configuration

{% if salt["grains.get"]("package-mirror") %}

/etc/fstab:
  file.touch

mirror-directory:
  mount.mounted:
    - name: /mirror
    - device: {{ salt["grains.get"]("package-mirror") }}:/srv/mirror
    - fstype: nfs
    - mkmnt: True
    - require:
      - file: /etc/fstab

rhn-conf-from-dir:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: server.susemanager.fromdir = /mirror
    - require:
      - sls: suse-manager
      - mount: mirror-directory

{% endif %}

{% endif %}
