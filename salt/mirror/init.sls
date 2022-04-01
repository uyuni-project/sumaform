include:
  - default
  - mirror.configuration
  - repos
  {% if not grains.get('disable_cron') %}
  - mirror.cron
  {% endif %}

{% if grains.get('synchronize_immediately') %}
synchronize_http_repositories :
   cmd.run:
     - name: bash /usr/local/bin/minima.sh
{% endif %}
