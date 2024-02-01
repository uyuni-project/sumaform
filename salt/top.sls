base:
  '*':
    - default

  'roles:server':
    - match: grain
    - server

  'roles:server_containerized':
    - match: grain
    - server_containerized

  'roles:client':
    - match: grain
    - client

  'roles:proxy':
    - match: grain
    - proxy

  'roles:proxy_containerized':
    - match: grain
    - proxy_containerized

  'roles:minion':
    - match: grain
    - minion

  'roles:mirror':
    - match: grain
    - mirror

  'roles:controller':
    - match: grain
    - controller

  'roles:grafana':
    - match: grain
    - grafana

  'roles:locust':
    - match: grain
    - locust

  'roles:virthost':
    - match: grain
    - virthost

  'roles:build_host':
    - match: grain
    - build_host

  'roles:jenkins':
    - match: grain
    - jenkins

  'roles:registry':
    - match: grain
    - registry

  'roles:salt_testenv':
    - match: grain
    - salt_testenv
