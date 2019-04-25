base:
  '*':
    - default

  'role:suse_manager_server':
    - match: grain
    - suse_manager_server

  'role:client':
    - match: grain
    - client

  'role:suse_manager_proxy':
    - match: grain
    - suse_manager_proxy

  'role:minion':
    - match: grain
    - minion

  'role:minionswarm':
    - match: grain
    - minionswarm

  'role:mirror':
    - match: grain
    - mirror

  'role:controller':
    - match: grain
    - controller

  'role:grafana':
    - match: grain
    - grafana

  'role:locust':
    - match: grain
    - locust

  'role:virthost':
    - match: grain
    - virthost
