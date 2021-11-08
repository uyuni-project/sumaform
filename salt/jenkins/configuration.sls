# base programs and services
parted:
  pkg.installed

tar:
  pkg.installed:
    - require:
      - sls: default

# partitioning

{% set fstype = grains.get('data_disk_fstype') | default('ext4', true) %}
jenkins_partition:
  cmd.run:
    - name: /usr/sbin/parted -s /dev/{{grains['data_disk_device']}} mklabel gpt && /usr/sbin/parted -s /dev/{{grains['data_disk_device']}} mkpart primary 2048 100% && sleep 1 && /sbin/mkfs.{{fstype}} /dev/{{grains['data_disk_device']}}1
    - unless: ls /dev//{{grains['data_disk_device']}}1
    - require:
      - pkg: parted

jenkins_directory:
  file.directory:
    - name: /var/lib/jenkins
    - mode: 775
    - makedirs: True
  mount.mounted:
    - name: /var/lib/jenkins
    - device: /dev/{{grains['data_disk_device']}}1
    - fstype: {{fstype}}
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: jenkins_partition

jenkins_install:
  pkg.installed:
    - name: jenkins-lts
    - require:
      - sls: default
  file.directory:
    - name: /var/lib/jenkins/secrets
    - mode: 700
    - user: jenkins
    - group: jenkins

# WORKAROUND: https://build.opensuse.org/package/show/devel:tools:building/jenkins-lts#comment-1543277
# Remove this state when the problem is fixed
jenkins_sysconfig:
  file.managed:
    - name: /etc/sysconfig/jenkins
    - source: /usr/share/fillup-templates/sysconfig.jenkins
    - require:
      - pkg: jenkins-lts
    - unless: ls /etc/sysconfig/jenkins
# End of WORKAROUND

jenkins_sysconfig_replace:
  file.replace:
    - name: /etc/sysconfig/jenkins
    - pattern: '^JENKINS_JAVA_OPTIONS="(.*)"$'
    - repl: 'JENKINS_JAVA_OPTIONS="\1 -Djenkins.install.runSetupWizard=false"'
    - unless:
      - grep '\-Djenkins.install.runSetupWizard=false' /etc/sysconfig/jenkins
    - require:
      # WORKAROUND: https://build.opensuse.org/package/show/devel:tools:building/jenkins-lts#comment-1543277
      # Remove the next line, and uncomment the next one when the problem is fixed
      - file: jenkins_sysconfig
      #- package: jenkins-lts
      # End of WORKAROUND

# This and the sysconfig change is needed so the Setup Wizard does not run
# and allow us the automated installation, while at the same time we still
# enable authentication and create an admin user (password can be found at
# /var/lib/jenkins/secrets/initialAdminPassword)
jenkins_security:
  file.managed:
    - name: /var/lib/jenkins/init.groovy.d/basic-security.groovy
    - source: salt://jenkins/basic-security.groovy
    - makedirs: True
    - dir_mode: 755
    - user: jenkins
    - group: jenkins
    - require:
      - pkg: jenkins-lts

# Enforce downloading the plugin list to avoid jenkins-cli failing when Jenkins
# already returns HTTP 200, but still didn't get the plugin list
jenkins_plugin_list:
  file.managed:
    - name: /var/lib/jenkins/updates/default.json
    - source: https://updates.jenkins-ci.org/update-center.json
    - skip_verify: True
    - makedirs: True
    - dir_mode: 755
    - user: jenkins
    - group: jenkins
    - require:
      - pkg: jenkins-lts

jenkins_plugin_list_fix:
  file.replace:
    - name: /var/lib/jenkins/updates/default.json
    - pattern: '^(updateCenter.post\(|\);)$'
    - repl: ''
    - require:
      - file: jenkins_plugin_list

jenkins_service:
  service.running:
    - name: jenkins
    - enable: True
    - require:
      - file: jenkins_sysconfig_replace
      - file: jenkins_security
      - file: jenkins_plugin_list

jenkins_configure:
  file.managed:
    - name: /tmp/configure-jenkins.sh
    - source: salt://jenkins/configure-jenkins.sh
    - mode: 755
    - require:
      - service: jenkins
  cmd.run:
    - name: /tmp/configure-jenkins.sh
    - require:
      - file: /tmp/configure-jenkins.sh
      - service: jenkins

web_server:
  pkg.installed:
    - name: apache2
    - require:
      - sls: default
  file.managed:
    - name: /etc/apache2/vhosts.d/jenkins.conf
    - source: salt://jenkins/etc/jenkins.conf
    - require:
      - pkg: apache2
  apache_module.enabled:
    - names:
      - proxy
      - proxy_http
    - require:
      - pkg: apache2
  service.running:
    - name: apache2
    - enable: True
    - require:
      - file: /etc/apache2/vhosts.d/jenkins.conf
      - apache_module: proxy
      - apache_module: proxy_http
      - service: jenkins
    - watch:
      - file: /etc/apache2/vhosts.d/jenkins.conf
