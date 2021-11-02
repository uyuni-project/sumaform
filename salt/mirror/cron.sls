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
      - pkg: cron
      - file: minima_script

apt-mirror_symlink:
  file.symlink:
    - name: /etc/cron.daily/apt-mirror.sh
    - target: /usr/local/bin/apt-mirror.sh
    - require:
      - pkg: cron
      - file: apt-mirror_script

mirror-images_symlink:
  file.symlink:
    - name: /etc/cron.daily/mirror-images.sh
    - target: /usr/local/bin/mirror-images.sh
    - require:
      - pkg: cron
      - file: mirror-images_script

scc-data_symlink:
  file.symlink:
    - name: /etc/cron.daily/scc-data.sh
    - target: /usr/local/bin/scc-data.sh
    - require:
      - pkg: cron
      - file: scc-data_script

# no symlinck by default for docker-images.sh
# (docker is not installed by default)
