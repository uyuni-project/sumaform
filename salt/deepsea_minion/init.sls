include:
  - minion
  - deepsea_minion.repos

deepsea_requirements:
  pkg.latest:
    - pkgs:
      - gptfdisk
    - require:
      - sls: minion
      - sls: deepsea_minion.repos
