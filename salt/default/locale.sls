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

fix_en_US_UTF8_as_system_locale_with_localectl:
  cmd.run:
    - name: localectl set-locale LANG=en_US.UTF-8
    - onlyif: test -f /usr/bin/localectl
