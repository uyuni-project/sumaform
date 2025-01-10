disable_all_local_repos:
  cmd.run:
    - name: zypper mr -d --all
    - onlyif: test -x /usr/bin/zypper
