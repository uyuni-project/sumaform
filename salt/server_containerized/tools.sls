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
    - name: mkdir -p bin && go build -o ./bin ./...
    - cwd: /root/uyuni-tools
    - require:
      - cmd: tools_repo_clone

uyunictl_symlink:
  file.symlink:
    - name: /usr/bin/uyunictl
    - target: /root/uyuni-tools/bin/uyunictl
    - require:
      - cmd: tools_built

uyuniadm_symlink:
  file.symlink:
    - name: /usr/bin/uyuniadm
    - target: /root/uyuni-tools/bin/uyuniadm
    - require:
      - cmd: tools_built
