build_packages:
  pkg.installed:
    - pkgs:
      - git-core
      - go1.20

tools_repo_clone:
  cmd.run:
    - name: git clone --depth 1 https://github.com/cbosdo/uyuni-tools /root/uyuni-tools
    - creates: /root/uyuni-tools
    - require:
      - pkg: build_packages


tools_built:
  cmd.run:
    - name: go build -o . ./...
    - cwd: /root/uyuni-tools
    - require:
      - cmd: tools_repo_clone

uyunictl_symlink:
  file.symlink:
    - name: /usr/bin/uyunictl
    - target: /root/uyuni-tools/uyunictl
    - require:
      - cmd: tools_built
