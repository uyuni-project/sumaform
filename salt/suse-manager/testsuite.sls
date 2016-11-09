{% if grains['for-testsuite-only'] %}

include:
  - suse-manager

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

/install:
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
