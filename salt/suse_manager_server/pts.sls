{% if grains.get('pts') %}
fio:
  pkg.installed

pts_runner:
  file.managed:
    - name: /usr/bin/run-pts
    - source: salt://suse_manager_server/pts/run-pts.py
    - template: jinja
    - mode: 755
    - require:
      - pkg: fio

create_symlink_for_pillar:
  file.symlink:
    - name: /srv/www/htdocs/pub/pillar_pts_minion.yml
    - target: /srv/susemanager/pillar_data/pillar_{{ grains.get('pts_minion') }}.tf.local.yml
    - force: true
{% endif %}
