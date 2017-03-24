base:
  '*':
    - default

  'role:suse-manager-server':
    - match: grain
    - suse-manager

  'role:client':
    - match: grain
    - client

  'role:suse-manager-proxy':
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

  'role:control-node':
    - match: grain
    - control-node
