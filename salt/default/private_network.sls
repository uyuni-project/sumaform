{% if grains.get('role') in ['suse_manager_proxy'] %}

etc_sysconfig_network_ifcfg_eth1:
  file.managed:
    - name: /etc/sysconfig/network/ifcfg-eth1
    - source: salt://default/ifcfg-eth1

eth1_up:
  cmd.run:
    - name: ifup eth1
    - require:
      - file: etc_sysconfig_network_ifcfg_eth1

dhcp_server:
  pkg.installed:
    - name: dhcp-server

etc_sysconfig_dhcpd:
  file.replace:
    - name: /etc/sysconfig/dhcpd
    - pattern: "DHCPD_INTERFACE=\"\""
    - repl: "DHCPD_INTERFACE=\"eth1\""
    - require:
      - pkg: dhcp_server

etc_dhcpd_conf:
  file.managed:
    - name: /etc/dhcpd.conf
    - source: salt://default/dhcpd.conf
    - require:
      - pkg: dhcp_server

dhcpd_service:
  service.running:
    - name: dhcpd
    - require:
      - cmd: eth1_up
      - file: etc_sysconfig_dhcpd
      - file: etc_dhcpd_conf

routing:
  cmd.run:
    - name: echo 1 > /proc/sys/net/ipv4/conf/all/forwarding

iptables:
  pkg.installed:
    - name: iptables

masquerading:
  cmd.run:
    - name: sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    - require:
      - pkg: iptables

{% elif grains.get('role') in ['suse_manager_server', 'controller'] %}

route:
  cmd.run:
    - name: if test -z "$(ip route show 192.168.5.0/24)"; then ip route add 192.168.5.0/24 via $(getent ahostsv4 ebi3-proxy.tf.local | head -n 1 | cut -d' ' -f1); fi

{% endif %}
