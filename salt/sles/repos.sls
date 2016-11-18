{% if grains['osrelease'] == '11.3' %}
sles-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-11-SP3-x86_64-Pool.repo
    - source: salt://sles/repos.d/SLE-11-SP3-x86_64-Pool.repo
    - template: jinja

sles-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-11-SP3-x86_64-Update.repo
    - source: salt://sles/repos.d/SLE-11-SP3-x86_64-Update.repo
    - template: jinja
{% endif %}

{% if grains['osrelease'] == '11.4' %}
sles-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-11-SP4-x86_64-Pool.repo
    - source: salt://sles/repos.d/SLE-11-SP4-x86_64-Pool.repo
    - template: jinja

sles-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-11-SP4-x86_64-Update.repo
    - source: salt://sles/repos.d/SLE-11-SP4-x86_64-Update.repo
    - template: jinja
{% endif %}

{% if grains['osrelease'] == '12' %}
sles-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-x86_64-Pool.repo
    - source: salt://sles/repos.d/SLE-12-x86_64-Pool.repo
    - template: jinja

sles-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-x86_64-Update.repo
    - source: salt://sles/repos.d/SLE-12-x86_64-Update.repo
    - template: jinja
{% endif %}

{% if grains['osrelease'] == '12.1' %}
sles-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP1-x86_64-Pool.repo
    - source: salt://sles/repos.d/SLE-12-SP1-x86_64-Pool.repo
    - template: jinja

sles-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP1-x86_64-Update.repo
    - source: salt://sles/repos.d/SLE-12-SP1-x86_64-Update.repo
    - template: jinja
{% endif %}

{% if grains['osrelease'] == '12.2' %}
sles-pool-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP2-x86_64-Pool.repo
    - source: salt://sles/repos.d/SLE-12-SP2-x86_64-Pool.repo
    - template: jinja

sles-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SLE-12-SP2-x86_64-Update.repo
    - source: salt://sles/repos.d/SLE-12-SP2-x86_64-Update.repo
    - template: jinja
{% endif %}

refresh-sles-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - require:
      - file: sles-pool-repo
      - file: sles-update-repo
