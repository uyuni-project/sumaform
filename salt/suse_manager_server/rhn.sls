{% if grains['for_development_only'] %}

include:
  - suse_manager_server

package_import_skip_changelog_reposync:
  file.append:
    - name: /etc/rhn/rhn.conf
    - text: package_import_skip_changelog = 1
    - require:
      - sls: suse_manager_server

{% if 'released' not in grains['version'] %}

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

{% if salt["grains.get"]("mirror") %}

non_empty_fstab:
  file.managed:
    - name: /etc/fstab
    - replace: false

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
