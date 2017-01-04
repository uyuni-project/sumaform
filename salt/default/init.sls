include:
  - default.repos

all-packages-up-to-date:
  pkg.uptodate:
    - order: last
    - require:
      - sls: default.repos
