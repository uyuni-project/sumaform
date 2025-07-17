{% if 'paygo' not in grains.get('product_version') | default('', true) and grains.get("osfullname") != "openSUSE Tumbleweed" %}
disable_all_local_repos:
  cmd.run:
    - name: zypper mr -d --all
    - onlyif: test -x /usr/bin/zypper
{% endif %}
