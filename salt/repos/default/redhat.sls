# Defines default repositories for RedHat family of distros

{% set release = grains.get('osmajorrelease', None)|int() %}
{% set version = grains.get('product_version', '') %}

{% if version.startswith('uyuni-') and release < 8 %}
    {% set rhlike_client_tools_prefix = 'CentOS' %}
{% elif release < 9 %}
    {% set rhlike_client_tools_prefix = 'RES' %}
{% else %}
  {% set rhlike_client_tools_prefix = 'EL' %}
{% endif %}

# Soon this key will be used for all non-suse repos. When it happens, replace galaxy_key with this
suse_el9_key:
  file.managed:
    - name: /tmp/suse_el9.key
    - source: salt://default/gpg_keys/suse_el9.key
  cmd.wait:
    - name: rpm --import /tmp/suse_el9.key
    - watch:
      - file: suse_el9_key

galaxy_key:
  file.managed:
    - name: /tmp/galaxy.key
    - source: salt://default/gpg_keys/galaxy.key
  cmd.wait:
    - name: rpm --import /tmp/galaxy.key
    - watch:
      - file: galaxy_key

suse_res7_key:
  file.managed:
    - name: /tmp/suse_res7.key
    - source: salt://default/gpg_keys/suse_res7.key
  cmd.wait:
    - name: rpm --import /tmp/suse_res7.key
    - watch:
      - file: suse_res7_key

{% if version.startswith('uyuni-') %}

uyuni_key:
  file.managed:
    - name: /tmp/uyuni.key
    - source: salt://default/gpg_keys/uyuni.key
  cmd.wait:
    - name: rpm --import /tmp/uyuni.key
    - watch:
      - file: uyuni_key

tools_pool_repo:
  pkgrepo.managed:
    - humanname: tools_pool_repo
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Stable:/{{ rhlike_client_tools_prefix }}{{ release }}-Uyuni-Client-Tools/{{ rhlike_client_tools_prefix }}_{{ release }}/
    - refresh: True
    - require:
      - cmd: uyuni_key

{% else %}

tools_pool_repo:
  pkgrepo.managed:
    - humanname: tools_pool_repo
    {%- if release >= 8 %}
      {%- if 'beta' in version %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/{{ rhlike_client_tools_prefix }}/{{ release }}-CLIENT-TOOLS-BETA/x86_64/product/
      {%- else %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/{{ rhlike_client_tools_prefix }}/{{ release }}-CLIENT-TOOLS/x86_64/product/
      {%- endif %}
    {%- elif grains.get('mirror') %}
      {%- if 'beta' in version %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/RES{{ release }}-SUSE-Manager-Tools-Beta/x86_64/
      {%- else %}
    - baseurl: http://{{ grains.get("mirror") }}/repo/$RCE/RES{{ release }}-SUSE-Manager-Tools/x86_64/
      {%- endif %}
    {%- else %}
      {%- if 'beta' in version %}
    - baseurl: http://download.suse.de/ibs/SUSE/Updates/RES/{{ release }}-CLIENT-TOOLS-BETA/x86_64/update/
      {%- else %}
    # Amazon Linux support
        {%- if release == 2 %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Products/RES/7-CLIENT-TOOLS/x86_64/product/
        {%- else %}
    - baseurl: http://download.suse.de/ibs/SUSE/Updates/RES/{{ release }}-CLIENT-TOOLS/x86_64/update/
        {%- endif %}
      {%- endif %}
    {%- endif %}
    - refresh: True
    - require:
      - cmd: galaxy_key
    {%- if release >= 9 %}
      - cmd: suse_el9_key
    {%- else %}
      - cmd: suse_res7_key
    {%- endif %}

suse_res6_key:
  file.managed:
    - name: /tmp/suse_res6.key
    - source: salt://default/gpg_keys/suse_res6.key
  cmd.wait:
    - name: rpm --import /tmp/suse_res6.key
    - watch:
      - file: suse_res6_key

{% endif %}

{% if release == 9 %}
  {% if salt['file.search']('/etc/os-release', 'Liberty') %}

os_pool_repo:
  pkgrepo.managed:
    - baseurl: http://rmt.scc.suse.de/repo/SUSE/Updates/SLL/9/x86_64/update
    - refresh: True

os_as_pool_repo:
  pkgrepo.managed:
    - baseurl: http://rmt.scc.suse.de/repo/SUSE/Updates/SLL-AS/9/x86_64/update
    - refresh: True

os_updates_repo:
  pkgrepo.managed:
    - baseurl: https://rmt.scc.suse.de/repo/SUSE/Updates/SLL/9/x86_64/update/?credentials=SUSE_Liberty_Linux_x86_64
    - refresh: True

os_as_updates_repo:
  pkgrepo.managed:
    - baseurl: https://rmt.scc.suse.de/repo/SUSE/Updates/SLL-AS/9/x86_64/update/?credentials=SUSE_Liberty_Linux_x86_64
    - refresh: True

os_cb_updates_repo:
  pkgrepo.managed:
    - baseurl: https://rmt.scc.suse.de/repo/SUSE/Updates/SLL-CB/9/x86_64/update/?credentials=SUSE_Liberty_Linux_x86_64
    - refresh: True

  {% endif %}
{% endif %}

{% if 'nightly' in version %}

tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/4.3:/{{ rhlike_client_tools_prefix }}{{ release }}-SUSE-Manager-Tools/SUSE_{{ rhlike_client_tools_prefix }}-{{ release }}_Update_standard/
    - refresh: True
    - require:
      - cmd: galaxy_key
    {%- if release >= 9 %}
      - cmd: suse_el9_key
    {%- else %}
      - cmd: suse_res7_key
    {%- endif %}

{% elif 'head' in version %}

tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de", true) }}/ibs/Devel:/Galaxy:/Manager:/Head:/{{ rhlike_client_tools_prefix }}{{ release }}-SUSE-Manager-Tools/SUSE_{{ rhlike_client_tools_prefix }}-{{ release }}_Update_standard/
    - refresh: True
    - require:
      - cmd: galaxy_key
    {%- if release >= 9 %}
      - cmd: suse_el9_key
    {%- else %}
      - cmd: suse_res7_key
    {%- endif %}

{% elif 'uyuni-master' in version or 'uyuni-pr' in version %}

tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    - baseurl: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/{{ rhlike_client_tools_prefix }}{{ release }}-Uyuni-Client-Tools/{{ rhlike_client_tools_prefix }}_{{ release }}/
    - refresh: True
    - gpgcheck: 1
    - gpgkey: http://{{ grains.get("mirror") | default("downloadcontent.opensuse.org", true) }}/repositories/systemsmanagement:/Uyuni:/Master:/{{ rhlike_client_tools_prefix }}{{ release }}-Uyuni-Client-Tools/{{ rhlike_client_tools_prefix }}_{{ release }}/repodata/repomd.xml.key
    - require:
      - cmd: uyuni_key

{% else %}
  {% if release >= 8 %}

tools_update_repo:
  pkgrepo.managed:
    - humanname: tools_update_repo
    {%- if 'beta' in version %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/{{ rhlike_client_tools_prefix }}/{{ release }}-CLIENT-TOOLS-BETA/x86_64/update/
    {%- else %}
    - baseurl: http://{{ grains.get("mirror") | default("download.suse.de/ibs", true) }}/SUSE/Updates/{{ rhlike_client_tools_prefix }}/{{ release }}-CLIENT-TOOLS/x86_64/update/
    {%- endif %}
    - refresh: True
    - require:
      - cmd: galaxy_key
      {%- if release >= 9 %}
      - cmd: suse_el9_key
      {%- else %}
      - cmd: suse_res7_key
      {%- endif %}

  {% endif %}
{% endif %}

clean_repo_metadata:
  cmd.run:
    - name: yum clean metadata
