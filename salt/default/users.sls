admin_group:
  group.present:
    - name: admin
    - system: True

admin_user:
  user.present:
    - name: admin
    - fullname: Administrator
    - shell: /bin/bash
    - home: /home/admin
    - createhome: True
    - password: '$6$haqmGlKACyoKh1ia$W/4MQxsR0wPohspYuJw.mFE25t5TRByTEdOw2atcPy7Qe0hrL7Jpq8ajSpuS5Zrp9uRgW4IDjpker7Zk56v9U.'
    -  uid: 1001
    - gid: admin
    - require:
        - group: admin_group
