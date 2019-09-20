base:
  '*':
    - default

  'roles:suse_manager_server':
    - match: grain
    - suse_manager_server

  'roles:client':
    - match: grain
    - client

  'roles:suse_manager_proxy':
    - match: grain
    - suse_manager_proxy

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

  'virtual_host:true':
    - match: grain
    - virthost
