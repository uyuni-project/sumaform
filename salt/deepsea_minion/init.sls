include:
  - minion
  - deepsea_minion.repos

deepsea:
  service.disabled:
    - name: apparmor
  pkg.latest:
    - pkgs:
      - gptfdisk
    - require:
      - sls: minion
      - sls: deepsea_minion.repos
