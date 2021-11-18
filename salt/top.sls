base:
  '*':
    - default

  'roles:server':
    - match: grain
    - server

  'roles:client':
    - match: grain
    - client

  'roles:proxy':
    - match: grain
    - proxy

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

  'roles:jenkins':
    - match: grain
    - jenkins

  'roles:registry':
    - match: grain
    - registry
