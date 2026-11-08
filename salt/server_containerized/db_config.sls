{# Uyuni/head store these settings in the rhnConfiguration table, not in rhn.conf #}
{% if grains.get('product_version', '') | regex_search('(uyuni|head)') %}

{% set db_settings = {} %}
{% if not grains.get('forward_registration') | default(false, true) %}
{% do db_settings.update({'SCC_FORWARD_REGISTRATION': '0'}) %}
{% endif %}
{% if grains.get('disable_auto_bootstrap') | default(false, true) %}
{% do db_settings.update({'AUTO_GENERATE_BOOTSTRAP_REPO': '0'}) %}
{% endif %}
{% if not grains.get('mirror') %}
{% do db_settings.update({'REPOSYNC_DOWNLOAD_THREADS': '2'}) %}
{% endif %}

{% for key, value in db_settings.items() %}
db_config_{{ key | lower }}:
  cmd.run:
    - name: mgrctl exec "echo \"UPDATE rhnConfiguration SET value = '{{ value }}' WHERE key = '{{ key }}';\" | spacewalk-sql -"
    - unless: mgrctl exec "echo \"SELECT 1 FROM rhnConfiguration WHERE key = '{{ key }}' AND value = '{{ value }}';\" | spacewalk-sql --select-mode -" | grep -q '^ *1'
    - require:
      - cmd: mgradm_install
{% endfor %}

{% endif %}
