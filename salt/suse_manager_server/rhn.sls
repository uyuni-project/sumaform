{% if grains['for_development_only'] %}

include:
  - suse_manager_server

incomplete_package_import_reposync:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: incomplete_package_import = 1
    - require:
      - sls: suse_manager_server

{% if 'stable' not in grains['version'] %}

browser_side_less_configuration:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: development_environment = true
    - require:
      - sls: suse_manager_server
  pkg.installed:
    - pkgs:
      - susemanager-frontend-libs-devel
      - spacewalk-branding-devel
    {% if '2.1' in grains['version'] %}
    - fromrepo: Devel_Galaxy_Manager_2.1
    {% endif %}
    - require:
      - sls: suse_manager_server

{% endif %}

create_first_user:
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
      - sls: suse_manager_server

create_empty_channel:
  cmd.run:
    - name: spacecmd -u admin -p admin -- softwarechannel_create --name testchannel -l testchannel -a x86_64
    - unless: spacecmd -u admin -p admin softwarechannel_list | grep -x testchannel
    - require:
      - http: create_first_user

create_activation_key:
  cmd.run:
    {% if '2.1' in grains['version'] %}
    - name: spacecmd -u admin -p admin -- activationkey_create -n DEFAULT -b testchannel -e provisioning_entitled
    {% else %}
    - name: spacecmd -u admin -p admin -- activationkey_create -n DEFAULT -b testchannel
    {% endif %}
    - unless: spacecmd -u admin -p admin activationkey_list | grep -x 1-DEFAULT
    - require:
      - cmd: create_empty_channel

create_bootstrap_script:
  cmd.run:
    - name: rhn-bootstrap --activation-keys=1-DEFAULT --no-up2date
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap.sh
    - require:
      - cmd: create_activation_key

create_bootstrap_script_md5:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/bootstrap/bootstrap.sh > /srv/www/htdocs/pub/bootstrap/bootstrap.sh.sha512
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap.sh.sha512
    - require:
      - cmd: create_bootstrap_script

private_ssl_key:
  file.copy:
    - name: /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY
    - source: /root/ssl-build/RHN-ORG-PRIVATE-SSL-KEY
    - mode: 644
    - require:
      - cmd: suse_manager_setup

private_ssl_key_checksum:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY > /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY.sha512
    - creates: /srv/www/htdocs/pub/RHN-ORG-PRIVATE-SSL-KEY.sha512
    - require:
      - file: private_ssl_key

ca_configuration:
  file.copy:
    - name: /srv/www/htdocs/pub/rhn-ca-openssl.cnf
    - source: /root/ssl-build/rhn-ca-openssl.cnf
    - mode: 644

ca_configuration_checksum:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/rhn-ca-openssl.cnf > /srv/www/htdocs/pub/rhn-ca-openssl.cnf.sha512
    - creates: /srv/www/htdocs/pub/rhn-ca-openssl.cnf.sha512
    - require:
      - file: ca_configuration

{% if salt["grains.get"]("mirror") %}

non_empty_fstab:
  file.touch:
    - name: /etc/fstab

mirror_directory:
  mount.mounted:
    - name: /mirror
    - device: {{ salt["grains.get"]("mirror") }}:/srv/mirror
    - fstype: nfs
    - mkmnt: True
    - require:
      - file: /etc/fstab

rhn_conf_from_dir:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: server.susemanager.fromdir = /mirror
    - require:
      - sls: suse_manager_server
      - mount: mirror_directory

{% elif salt["grains.get"]("smt") %}

rhn_conf_mirror:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: server.susemanager.mirror = {{ salt["grains.get"]("smt") }}
    - require:
      - sls: suse_manager_server

{% endif %}

{% endif %}
