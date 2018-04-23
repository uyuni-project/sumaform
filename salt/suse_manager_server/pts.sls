{% if grains.get('pts') %}
pts_runner:
  file.managed:
    - name: /usr/bin/run-pts
    - source: salt://suse_manager_server/pts/run-pts.py
    - template: jinja
    - mode: 755

create_symlink_for_pillar:
  file.symlink:
    - name: /srv/www/htdocs/pub/pillar_data
    - target: /srv/susemanager/pillar_data
    - force: true
{% endif %}
