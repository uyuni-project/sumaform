base:
  '*':
    - default

  'role:suse_manager_server':
    - match: grain
    - suse-manager

  'role:client':
    - match: grain
    - client

  'role:suse_manager_proxy':
    - match: grain
    - suse-manager-proxy

  'role:minion':
    - match: grain
    - minion

  'role:minionswarm':
    - match: grain
    - minionswarm

  'role:mirror':
    - match: grain
    - mirror

  'role:postgres':
    - match: grain
    - postgres

  'role:controller':
    - match: grain
    - controller
