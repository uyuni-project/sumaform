cron:
  pkg.installed

cron_service:
  service.running:
    - name: cron
    - enable: True
    - require:
      - pkg: cron

minima_symlink:
  file.symlink:
    - name: /etc/cron.daily/minima.sh
    - target: /usr/local/bin/minima.sh
    - require:
      - file: minima_script

apt-mirror_symlink:
  file.symlink:
    - name: /etc/cron.daily/apt-mirror.sh
    - target: /usr/local/bin/apt-mirror.sh
    - require:
      - file: apt-mirror_script

mirror-images_symlink:
  file.symlink:
    - name: /etc/cron.daily/mirror-images.sh
    - target: /usr/local/bin/mirror-images.sh
    - require:
      - file: mirror-images_script

scc-data_symlink:
  file.symlink:
    - name: /etc/cron.daily/scc-data.sh
    - target: /usr/local/bin/scc-data.sh
    - require:
      - file: scc-data_script
