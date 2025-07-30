{% if grains.get('transactional', False) %}
copy_salt_classic_testsuite:
  cmd.run:
    - name: transactional-update -c run cp -r /usr/lib/python3.{{ grains["pythonversion"][1] }}/site-packages/salt-testsuite /opt/salt-testsuite-classic

copy_salt_bundle_testsuite:
  cmd.run:
    - name: transactional-update -c run cp -r /usr/lib/venv-salt-minion/lib/python3.{{ grains["pythonversion"][1] }}/site-packages/salt-testsuite /opt/salt-testsuite-bundle

disable_rebootmgr_to_avoid_reboots:
  file.managed:
    - name: /etc/rebootmgr.conf
    - contents: |
            [rebootmgr]
            strategy=off

reboot_transactional_system:
  module.run:
    - name: system.reboot
    - at_time: +1
    - order: last
{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []
