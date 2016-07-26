include:
  - sles.repos

{% if grains['osrelease'] == '11.3' %}
sle-manager-tools-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-11-SP3-x86_64.repo
    - source: salt://client/repos.d/SLE-Manager-Tools-SLE-11-SP3-x86_64.repo
    - template: jinja

sle-manager-tools-update-repo:
  file.touch:
    - name: /tmp/no_update_channel_needed
{% endif %}

{% if grains['osrelease'] == '11.4' %}
sle-manager-tools-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-11-SP4-x86_64.repo
    - source: salt://client/repos.d/SLE-Manager-Tools-SLE-11-SP4-x86_64.repo
    - template: jinja

sle-manager-tools-update-repo:
  file.touch:
    - name: /tmp/no_update_channel_needed
{% endif %}

{% if grains['osrelease'] == '12' %}
sle-manager-tools-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Pool.repo
    - source: salt://client/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Pool.repo
    - template: jinja

sle-manager-tools-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Update.repo
    - source: salt://client/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Update.repo
    - template: jinja
{% endif %}

{% if grains['osrelease'] == '12.1' %}
sle-manager-tools-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Pool.repo
    - source: salt://client/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Pool.repo
    - template: jinja

sle-manager-tools-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Update.repo
    - source: salt://client/repos.d/SLE-Manager-Tools-SLE-12-x86_64-Update.repo
    - template: jinja
{% endif %}

refresh-client-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - sls: sles.repos
      - file: sle-manager-tools-pool-repo
      - file: sle-manager-tools-update-repo
