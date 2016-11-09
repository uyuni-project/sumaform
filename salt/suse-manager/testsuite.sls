{% if grains['for-testsuite-only'] %}

include:
  - suse-manager

testsuite-authorized-key:
  file.managed:
    - name: /root/.ssh/authorized_keys
    - source: salt://control-node/id_rsa.pub
    - makedirs: True
    - user: root
    - group: root
    - mode: 700

anaconda-package-file:
  file.managed:
    - name: /root/anaconda-18.37.11-1.fc18.x86_64.rpm
    - source: salt://suse-manager/test-server/anaconda-18.37.11-1.fc18.x86_64.rpm

subscription-tools-package-file:
  file.managed:
    - name: /root/subscription-tools-1.0-0.noarch.rpm
    - source: salt://suse-manager/test-server/subscription-tools-1.0-0.noarch.rpm

test-autoinstallation-directory:
  file.recurse:
    - name: /install
    - source: salt://suse-manager/test-server/install

test-public-directory:
  file.recurse:
    - name: /srv/www/htdocs/pub/
    - source: salt://suse-manager/test-server/pub

test-vcenter-file:
  file.managed:
    - name: /tmp/vCenter.json
    - source: salt://suse-manager/test-server/vCenter.json

# modify cobbler to be executed from remote-machines.. 

config-cobbler:
    service:
    - name : cobblerd.service
    - running
    - enable: True
    - watch : 
      - file : /etc/cobbler/settings
    - require:
      - sls: suse-manager
    file.replace:
    - name: /etc/cobbler/settings
    - pattern: "redhat_management_permissive: 0"
    - repl: "redhat_management_permissive: 1"
    - require:
      - sls: suse-manager

expect:
  pkg.installed

{% endif %}
