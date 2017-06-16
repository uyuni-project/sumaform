include:
  - default.repos

up_to_date_salt:
  pkg.latest:
    - pkgs:
      - salt
      - salt-minion
    - order: last
    - require:
      - sls: default.repos
