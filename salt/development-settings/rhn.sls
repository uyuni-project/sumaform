include:
  - suse-manager

{% if 'stable' not in salt['grains.get']('version', '') %}

browser side LESS compilation:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: development_environment = true
    - require:
      - sls: suse-manager
  pkg.installed:
    - pkgs:
      - susemanager-frontend-libs-devel
      - spacewalk-branding-devel
    {% if '2.1' in salt['grains.get']('version', '') %}
    - fromrepo: Devel_Galaxy_Manager_2.1
    {% endif %}
    - require:
      - sls: suse-manager

{% endif %}

first user:
  http.query:
    - method: POST
    {% if '2.1' in salt['grains.get']('version', '') %}
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

empty test channel:
  cmd.run:
    - name: spacecmd -u admin -p admin -- softwarechannel_create --name testchannel -l testchannel -a x86_64
    - unless: spacecmd -u admin -p admin softwarechannel_list | grep -x testchannel
    - require:
      - http: first user

default activation key:
  cmd.run:
    - name: spacecmd -u admin -p admin -- activationkey_create -n DEFAULT -b testchannel
    - unless: spacecmd -u admin -p admin activationkey_list | grep -x 1-DEFAULT
    - require:
      - cmd: empty test channel

default bootstrap script:
  cmd.run:
    - name: rhn-bootstrap --activation-keys=1-DEFAULT --no-up2date
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap.sh
    - require:
      - cmd: default activation key

default bootstrap script md5:
  cmd.run:
    - name: sha512sum /srv/www/htdocs/pub/bootstrap/bootstrap.sh > /srv/www/htdocs/pub/bootstrap/bootstrap.sh.sha512
    - creates: /srv/www/htdocs/pub/bootstrap/bootstrap.sh.sha512
    - require:
      - cmd: default bootstrap script

{% if salt["grains.get"]("package-mirror") %}

/mirror:
  mount.mounted:
    - device: {{ salt["grains.get"]("package-mirror") }}:/srv/mirror
    - fstype: nfs
    - mkmnt: True

configure from dir:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: server.susemanager.fromdir = /mirror
    - require:
      - sls: suse-manager
      - mount: /mirror

{% endif %}
