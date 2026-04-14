{% set use_localectl = true %}
{% if grains['os_family'] == 'Debian' and grains.get('osmajorrelease', 0)|int() == 13 %}
{% set use_localectl = false %}
{% endif %}

{% if grains['os_family'] == 'Suse' %}
manually_set_locale_rc_lang:
  file.replace:
    - name: /etc/sysconfig/language
    - pattern: ^RC_LANG=".*"
    - repl: RC_LANG="en_US.UTF-8"
    - onlyif: test ! -f /usr/bin/localectl

manually_set_locale_root_uses_lang:
  file.replace:
    - name: /etc/sysconfig/language
    - pattern: ^ROOT_USES_LANG=".*"
    - repl: ROOT_USES_LANG="ctype"
    - onlyif: test ! -f /usr/bin/localectl

manually_set_locale_installed_languages:
  file.replace:
    - name: /etc/sysconfig/language
    - pattern: ^INSTALLED_LANGUAGES=".*"
    - repl: INSTALLED_LANGUAGES=""
    - onlyif: test ! -f /usr/bin/localectl

{% elif grains['os_family'] == 'RedHat' %}

{% if grains.get('osmajorrelease', None)|int() == 9 %}
langpack_package:
  pkg.installed:
    - name: glibc-langpack-en
{% endif %}

{% endif %}

{% if use_localectl %}
fix_en_US_UTF8_as_system_locale_with_localectl:
  cmd.run:
    - name: localectl set-locale LANG=en_US.UTF-8
    - onlyif: test -f /usr/bin/localectl

{% else %}
configure_locale_gen:
  file.append:
    - name: /etc/locale.gen
    - text: en_US.UTF-8 UTF-8

generate_locales:
  cmd.run:
    - name: locale-gen
    - onchanges:
      - file: configure_locale_gen

fix_en_US_UTF8_as_system_locale_with_update_locale:
  cmd.run:
    - name: update-locale LANG=en_US.UTF-8
{% endif %}
