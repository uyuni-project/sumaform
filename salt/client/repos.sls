include:
  - sles

# client repos are a superset of sles repos, ensure they are present
sles-repos:
  test.nop:
    - require:
      - sls: sles

{% if grains['osrelease'] == '11.3' %}
sle-manager-tools-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-11-SP3-x86_64.repo
    - source: salt://client/repos.d/SLE-Manager-Tools-SLE-11-SP3-x86_64.repo
    - template: jinja
{% endif %}

{% if grains['osrelease'] == '11.4' %}
sle-manager-tools-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-Manager-Tools-SLE-11-SP4-x86_64.repo
    - source: salt://client/repos.d/SLE-Manager-Tools-SLE-11-SP4-x86_64.repo
    - template: jinja
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
