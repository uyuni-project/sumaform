base:
  '*':
    - default

  'role:spacewalk-server':
    - match: grain
    - spacewalk

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

  'role:package-mirror':
    - match: grain
    - package-mirror

  'role:minion-swarm-host':
    - match: grain
    - minion-swarm-host

  'role:postgres':
    - match: grain
    - postgres

  'role:control-node':
    - match: grain
    - control-node
