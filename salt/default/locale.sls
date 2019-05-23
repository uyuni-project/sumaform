fix_en_US_UTF8_as_system_local:
  cmd.run:
    - name: localectl set-locale LANG=en_US.UTF-8
