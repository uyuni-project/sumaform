{% if grains.get('osmajorrelease', None)|int() == 11 %}

set_locale_rc_lang_on_sle11:
  file.replace:
    - name: /etc/sysconfig/language
    - pattern: ^RC_LANG=".*"
    - repl: RC_LANG="en_US.UTF-8"

set_locale_root_uses_lang_on_sle11:
  file.replace:
    - name: /etc/sysconfig/language
    - pattern: ^ROOT_USES_LANG=".*"
    - repl: ROOT_USES_LANG="ctype"

set_locale_installed_languages_on_sle11:
  file.replace:
    - name: /etc/sysconfig/language
    - pattern: ^INSTALLED_LANGUAGES=".*"
    - repl: INSTALLED_LANGUAGES=""

{% else %}

fix_en_US_UTF8_as_system_local:
  cmd.run:
    - name: localectl set-locale LANG=en_US.UTF-8

{% endif %}
