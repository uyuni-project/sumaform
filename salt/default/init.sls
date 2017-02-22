include:
  - default.repos
  - default.pkgs

up-to-date-salt:
  pkg.latest:
    - name: salt
    - order: last
    - require:
      - sls: default.repos
