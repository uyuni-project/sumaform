base:
  '*':
    - default

  'role:suse_manager_server':
    - match: grain
    - suse_manager_server

  'role:suse_manager_deepsea_server':
    - match: grain
    - suse_manager_deepsea_server

  'role:client':
    - match: grain
    - client

  'role:suse_manager_proxy':
    - match: grain
    - suse_manager_proxy

  'role:minion':
    - match: grain
    - minion

  'role:deepsea_minion':
    - match: grain
    - deepsea_minion

  'role:minionswarm':
    - match: grain
    - minionswarm

  'role:evil_minions':
    - match: grain
    - evil_minions

  'role:mirror':
    - match: grain
    - mirror

  'role:postgres':
    - match: grain
    - postgres

  'role:controller':
    - match: grain
    - controller

  'role:grafana':
    - match: grain
    - grafana
